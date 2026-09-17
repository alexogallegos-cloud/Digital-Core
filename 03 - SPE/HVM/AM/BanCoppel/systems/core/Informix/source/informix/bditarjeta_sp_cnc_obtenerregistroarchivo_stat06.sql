CREATE PROCEDURE "informix".sp_cnc_obtenerregistroarchivo_stat06 
(
	psNomArchivo VARCHAR (23),     --  Nombre del archivo el cual se esta cargando
	psArchivoOrigen VARCHAR(3),    --  Abreviatura del archivo
	piTipoLayOut INTEGER, 		   --  Tipo de layout
	psCve_Usuario VARCHAR(10)      --  Usuario del sistema 
)

RETURNING VARCHAR (5) AS CodRet, VARCHAR(250) AS Mensaje_Respuesta, INTEGER AS Elemento;

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

	-- SET DEBUG FILE TO "/informix/LVRQ/SecuenciayATM/debug/obtieneregistro.out";
	-- TRACE ON;

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
		-- SET DEBUG FILE TO "/home/c90296115/exc_sp_cnc_obtener_registro_archivo.out" WITH APPEND;
		-- TRACE ON;
		
		TRUNCATE TABLE bditarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		BEGIN WORK;
		
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCIONPENDIENTE PARA TABLA td_movimientos_cnc_coppel_pay.								
		DELETE FROM BdiTarjeta:"informix".td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen; 
		
		COMMIT WORK;
		
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
		END IF;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
		TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06;
		COMMIT WORK;
		
		BEGIN WORK;
		
		-- BORRA LOS REGISTROS QUE SE INSERTARON EN LA TABLA.
		DELETE FROM BdiTarjeta:"informix".Td_Movimientos_Conciliacion WHERE NombreArchivo = psNomArchivo AND Archivo_Origen = psArchivoOrigen;
		
		LET vsCodRet = '00200';	
		
		RETURN vsCodRet, ('[' || vsCodRet ||  ']ERROR NO CONTROLADO (' || viSQLerr || '). ARCHIVO (' || psNomArchivo || ') ' || TRIM(vsMensaje_Respuesta) ), 2;
	
	END EXCEPTION;
	
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET vsFlagEnTransaccion = 'F';
	LET viContadorRegistros = 0;
	
	-- Se elimina el registro con el detalle total de tsn y monto
	DELETE FROM BdiTarjeta:"informix".td_carga_archivo_stat06 
	WHERE (Registro MATCHES '        Total de Transacciones: *' );
	
	SELECT COUNT(*) 
	INTO iTotRegistrosAux
	FROM Td_Movimientos_Conciliacion 
	WHERE NombreArchivo = psNomArchivo 
	AND Archivo_Origen = psArchivoOrigen;

	IF iTotRegistrosAux = iTotRegEglobal AND iTotRegEglobal <> 0 THEN
	
		--REPROCESO.
		DELETE FROM Td_Movimientos_Conciliacion 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
		
		DELETE FROM td_movimientos_cnc_coppel_pay 
		WHERE NombreArchivo = psNomArchivo 
		AND Archivo_Origen = psArchivoOrigen;
	end if
	
    FOREACH WITH HOLD

		-- RECORRE LA TABLA PARA OBTENER LOS REGISTROS
		-- Esta tabla es de paso, y se emplea para carga la informacion de los archivos de conciliacion
		-- solo tiene un campo, por tanto es esperado el sequential scan
		SELECT Registro
		INTO vsRegistro
		FROM BdiTarjeta:"informix".td_carga_archivo_stat06
		
		IF (vsFlagEnTransaccion = 'F') THEN 
			BEGIN WORK;
			LET vsFlagEnTransaccion = 'V';
		END IF;

		IF ((piTipoLayOut = 4) or (piTipoLayOut = 7)) THEN -- ATM BANCOPPEL y ATM IST
			LET vsbin =  TRIM(SUBSTR (vsRegistro,37,6));
			LET vsnumtarjetaini = TRIM(SUBSTR (vsRegistro,37,16));
		END IF;
			
		-- OBTENCION DE NUMERO CUENTA DEBIDO A QUE TRAIA MAS DE UNA CUENTA EL REGISTRO 
		SELECT FIRST 1 numcuenta  
		INTO vscuenta 
		FROM Intercard:"informix".tarjetacuenta
		where  numcuenta != ''
		AND numtarjeta = vsnumtarjetaini;
	
		if vscuenta is null or vscuenta = '' then
			let vscuenta = '000000000000';
		END IF;
		
		if (vsbin <> 'NPT')  then
			select creditodebito, prefijo 
			into vstpotarjeta, vsprefijo 
			from Intercard:"informix".bines 
			where bin = vsbin;
		END IF;

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
		
		LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA CONCILIACION_ATM_STAT06.';
		
		IF (piTipoLayOut = 7) THEN 
			
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
			
			LET vsMensaje_Respuesta = 'INSERTAR REGISTRO EN LA TABLA TD_MOVIMIENTOS_CONCILIACION';	
			
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
		END IF;
		
		IF (piTipoLayOut = 7) THEN
			LET viContadorRegistros = viContadorRegistros + 2;
		ELSE 
			LET viContadorRegistros = viContadorRegistros + 1;		
		END IF;
		
		LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
		
		-- TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros >= 1000) THEN                
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
	END FOREACH;

	LET vsMensaje_Respuesta = 'TERMINAR TRANSACCION';
	
	-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
	
	IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN -- VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
		COMMIT WORK;
		LET vsFlagEnTransaccion = 'F';
        LET viContadorRegistros = 0;
	END IF;
	
	LET vsMensaje_Respuesta = 'BORRAR CONTENIDO DE TD_CARGA_ARCHIVO_STAT06.';
	
	BEGIN WORK;	
	
	LET vsFlagEnTransaccion = 'V';

	-- BORRA LOS REGISTROS DEL ARCHIVO ALMACENADOS EN LA TABLA DE CARGA
    TRUNCATE TABLE BdiTarjeta:"informix".td_carga_archivo_stat06 DROP STORAGE;

	COMMIT WORK;
	
	LET vsFlagEnTransaccion = 'F';
	LET vsMensaje_Respuesta = '';

	RETURN vsCodRet, vsMensaje_Respuesta, 2;
END
END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de parsear la ifnromacion del archivo de conciliacion ATM STAT06 para guardar los datos en la tabla principal de la conciliacion',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_concreing_validaintegridad_stat06 
( 
	psArchivo_origen CHAR (3), 
	psConsecutivo INTEGER,
	psNumTarjeta CHAR(16),
	psTipotransaccion325 CHAR(15),
	pmMonto325 CHAR(13),
	pmMontoCashBack325 CHAR (13), 
	psIdcomercio325 CHAR(15), 
	psNomcomercio325 CHAR(30),
	psReferencia23_325 CHAR(23),
	psSecuencia325 CHAR(6),
	psDivisa325 CHAR(3), 
	psRfc325 CHAR(16),
	psBinDebito CHAR(6), 
	psBinCredito CHAR(6),
	psSistema CHAR(1)
)

RETURNING CHAR (5) AS Retorno, CHAR (1) AS Integridad, CHAR(250) AS ErrorActividad, INTEGER AS Elemento;

	/*VARIABLES DE ERRORES*/
	DEFINE vsIntegridad	CHAR(1);
	DEFINE vsErrorIntegridad CHAR(20);
	DEFINE vsErrorActividad	CHAR(250);

	DEFINE viCodigo INTEGER;
	DEFINE vssqlerr CHAR(5) ;
	DEFINE vsFlagError CHAR (1) ;

	DEFINE vsEsNumTarjeta	CHAR(1);
	DEFINE vsEsIdComercio	CHAR(1);
	DEFINE vsEsReferencia23_325	CHAR(1);
	DEFINE vsEsSecuencia325	CHAR(1);
	DEFINE vsEsDivisa325	CHAR(1);
	DEFINE vsEsMonto		CHAR(1);
	--DEFINE vmMonto325 MONEY(19,4);
	DEFINE vmMonto325 MONEY;
	DEFINE vsEsMontoCashBack325 CHAR(1);
	DEFINE vmMontoCashBack325 MONEY;

	DEFINE vsBine	CHAR(6);

	/* INICIALIZACION DE VARIABLES */
	LET vsIntegridad = '';
	LET vsErrorIntegridad = '';
	LET vsErrorActividad = '';

	LET vsEsNumTarjeta = '';
	LET vsEsIdComercio = '';
	LET vsEsReferencia23_325 = '';
	LET vsEsSecuencia325 = '';
	LET vsEsDivisa325 = '';
	LET vsEsMonto = '';
	LET vmMonto325 = 0;
	LET vsEsMontoCashBack325 = '';
	LET vmMontoCashBack325 = 0;
	
	LET vsBine = '';

	LET viCodigo = 0;
	LET vssqlerr = '00000';
	LET vsFlagError = '' ;

	BEGIN

		ON EXCEPTION SET viCodigo   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = viCodigo;
				LET vsFlagError = 'F';

				RETURN vssqlerr, vsFlagError, vsErrorActividad, 3;

		END EXCEPTION;

		--SET DEBUG FILE TO '/home/c90296115/TraceINTEGRIDAD_mike.out';
		--TRACE ON;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		/*OBTENIENDO LA CIFRA DEL BIN DE LA TARJETA*/
		
		LET vsBine = NVL(SUBSTRING (psNumTarjeta FROM 1 FOR 6),'');
		LET vmMonto325 = ( ( REPLACE( pmMonto325,'.',''))::MONEY/100 );
		LET vmMontoCashBack325 = ((REPLACE (pmMontoCashBack325,'.',''))::MONEY/100); --Conversion de string de monto cashback a money
		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_EsNumerico ( psNumTarjeta ) INTO vsEsNumTarjeta;

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS E-GLOBAL VENTAS INTERNACIONALES
		-- BCPLVID Y BCPLVIC
		IF TRIM(NVL(psArchivo_origen,''))='' THEN
			
			LET vssqlerr = '00307';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';

		-- VALIDACION DE INTEGRIDAD DE REGISTROS - ARCHIVOS PROSA
		-- BCPL_ATMOL Y BCPL_ATMPL
		ELIF ( ( psArchivo_origen = 'TMO' ) OR ( psArchivo_origen = 'TMP' ) OR ( psArchivo_origen = 'IST' ) ) THEN
			LET vssqlerr = '00305';
			--VALIDANDO QUE LOS CAMPOS SEAN NUMERICOS

			--VALIDACION DEL NUMERO DE TARJETA
			IF LENGTH(psNumTarjeta)!=16 THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR1 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: DEBE SER IGUAL A 16 CARACTERES';
				
			ELIF TRIM(NVL(psNumTarjeta,''))='' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR2 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE ESTAR VACIO';
				
			ELIF (vsEsNumTarjeta != 'V' ) THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR3 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: SOLO DEBE CONTENER DIGITOS';
				
			ELIF psNumTarjeta = '0000000000000000' THEN
			
				LET vsIntegridad = 'F';
				LET vsErrorIntegridad = 'ERROR4 numtarjeta';
				LET vsErrorActividad = 'ERROR DE INTEGRIDAD numtarjeta: NO DEBE TENER SOLO CEROS';
				
			ELSE
			
				LET vssqlerr = '00000';

				LET vsIntegridad = 'V';
				LET vsErrorIntegridad = '';

			END IF;

		ELSE
			LET vssqlerr = '00306';
			
			/*SE HA MANDADO COMO PARAMETRO OTRO TIPO DE ARCHIVO*/
			LET vsIntegridad = 'F';
			LET vsErrorIntegridad = 'ERROR archivo_origen';
			LET vsErrorActividad = 'ERROR DE INTEGRIDAD archivo_origen: EL VALOR DEL ARCHIVO ORIGEN ES INCORRECTO';
			
		END IF;

			/*ACTUALIZAR VARIABLES DE RETORNO*/
			LET vsFlagError = vsIntegridad;
		
			UPDATE bditarjeta:"informix".td_movimientos_conciliacion
			SET integridad = vsIntegridad, integridad_error = vsErrorIntegridad
			WHERE consecutivo = psConsecutivo;

			IF (vsIntegridad NOT IN ('V')) THEN

				LET vsErrorActividad ='CONSECUTIVO '|| psConsecutivo || ' CONTIENE ' || vsErrorActividad;
				
				IF (vssqlerr = '00305') THEN 
					EXECUTE PROCEDURE BdiTarjeta:"informix".sp_cnc_guardabitacora_stat06 ('3', '(' || psConsecutivo || ') ' || vsErrorActividad, 'sysconau');
					LET vssqlerr = '00000';
				END IF;
				
			END IF;

		RETURN vssqlerr, NVL(vsFlagError,''),'', 3 ;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de valdiar la integridad de los registros del archivo de conciliacion de ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_guardabitacora_stat06
(
	psElemento INTEGER,
	psActividad CHAR(150),
	psCve_usuario CHAR(10)
)

	RETURNING CHAR(5) AS Retorno;

	/*DEFINICION DE VARIABLES*/

	/*VARIABLES DE RETORNO*/
	DEFINE visqlerr INTEGER ;
	DEFINE vssqlerr CHAR(5);
	DEFINE vsFechaHora DATETIME YEAR TO FRACTION(5);

	/*INICIALIZACION DE VARIABLES*/
	LET visqlerr = 0;
	LET vssqlerr = '00000';
	LET vsFechaHora = CURRENT;

	BEGIN

		ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado

				LET vssqlerr = visqlerr;
				RETURN vssqlerr;

		END EXCEPTION;

		
		-- SET DEBUG FILE TO '/home/c90296115/guardaBitacoraDep.txt';
		-- TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;

		INSERT INTO bditarjeta:"informix".td_bitacora_conciliacion_atm_stat06 (elemento, fecha_hora, actividad, cve_usuario)
		VALUES (psElemento,vsFechaHora,psActividad,psCve_usuario);

		LET vssqlerr = '00000';

	RETURN vssqlerr;

	END

END PROCEDURE
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Bitacora conciliacion ATM STAT06',
'Fecha: 2023/12/06',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_cnc_obt_archivo_stat06()

	RETURNING VARCHAR (5) AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
	
	/* DEFINICION DE VARIABLES */

	-- CONTROL DE ERRORES
		
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
		
	--CONTROL GENERAL
	
	DEFINE CODIGO				CHAR (6);
	DEFINE MENSAJE_RPTA			CHAR (80);
	DEFINE vRUTA_ESTAT_06		CHAR (33);
	DEFINE vCodigo				CHAR (6);
	DEFINE vListArchivo			CHAR (20);
	DEFINE vArchiBat			CHAR (20);
	DEFINE vExecuteSQL 			CHAR (300);
	DEFINE vsNombreArchivo 		CHAR (30);
	DEFINE dsFechaArchivo 		CHAR (10);
	DEFINE FlagTrace 		CHAR (10);
			
	BEGIN	
				
		ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			LET CODIGO    		= SQL_ERR;
			LET MENSAJE_RPTA  	= ERROR_INFO;

			DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
			
			RETURN CODIGO, MENSAJE_RPTA;
		  
		END EXCEPTION;
				
		--SET DEBUG FILE TO "/home/c90296115/nombre_archivo_atm_stat06.out";
		--TRACE ON;
				
		/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
		
		LET CODIGO					= '00000';
		LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
		LET vRUTA_ESTAT_06			= '';
		LET vCodigo					= '00000';
		LET vListArchivo			= 'listado_archivos.txt';
		LET vArchiBat				= 'bat_stat06.bat';
		LET vExecuteSQL				= '';
		LET vsNombreArchivo			= '';
		LET dsFechaArchivo			= '';
		LET FlagTrace				= '';
		
		
		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;
		
		LET FlagTrace = 'Se inicializan excepciones ';
		
		-- ELIMINA LOS RESGISTROS DE LA TABLA CARGADOS ANTERIORMENTE
		DELETE FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06;
					
		---DEFINE  Ruta de obtencion  
		SELECT rep_aix
		INTO vRUTA_ESTAT_06
		FROM bditarjeta:td_archivo_origen_atm_stat06
		WHERE archivo_origen = "IST";
		
		
	LET FlagTrace = 'Se obtuvo la ruta de la tabla ';	 
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "ls '|| vRUTA_ESTAT_06|| '| grep BCPL_STAT06_ " > ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 1';	
		LET vExecuteSQL ='';
		LET vExecuteSQL= 'chmod 777 ' || vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 2';	
		LET vExecuteSQL = ''; 
		LET vExecuteSQL =  vRUTA_ESTAT_06||'/'||vArchiBat ||'>'|| vRUTA_ESTAT_06||'/'||vListArchivo; 
		SYSTEM vExecuteSQL; 
	LET FlagTrace = 'Paso 3';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vArchiBat;
		system vExecuteSQL;
	LET FlagTrace = 'Paso 4';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'echo "LOAD FROM '|| TRIM(vRUTA_ESTAT_06) || '/' || TRIM(vListArchivo) ||
						 ' INSERT INTO bditarjeta:td_cga_nombre_archivo_atm_stat06;" > ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 5';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'dbaccess bditarjeta ' || TRIM(vRUTA_ESTAT_06) ||  '/load_nombre_archivo.sql';
		SYSTEM vExecuteSQL;
	LET FlagTrace = 'Paso 6';
		LET vExecuteSQL = '';
		LET vExecuteSQL = 'rm '||vRUTA_ESTAT_06||'/'||vListArchivo;
		system vExecuteSQL;
		
				
		FOREACH cursor_archivo FOR
				
			SELECT nom_archivo_stat06
				INTO vsNombreArchivo
			FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06
			                       
			IF SUBSTR(vsNombreArchivo,19,4) = '.txt' THEN
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'Registrando archivo ' || vsNombreArchivo || 'para procesar.' , 'sysconau')
				INTO vCodigo;
				
				LET dsFechaArchivo = TRIM(SUBSTR (vsNombreArchivo,13,6));
				LET dsFechaArchivo = SUBSTR(dsFechaArchivo,3,2)||'/'||SUBSTR(dsFechaArchivo,1,2)||'/'||SUBSTR(dsFechaArchivo,5,2);
				LET dsFechaArchivo = dsFechaArchivo::DATE;
				LET FlagTrace = 'Proceso el nombre del archivo para inserta';			
				-- TRACE 'SOY FECHA ARCHIVO '||dsFechaArchivo;
			
				INSERT INTO bditarjeta:"informix".td_archivos_conciliacion_atm_stat06
					(nombrearchivo,
					archivo_origen,
					fecha_archivo,
					num_registros325,
					monto325,
					fecha_proceso,
					fecha_hora_transferencia, 
					fecha_hora_ini_proceso, 
					fecha_hora_carga_archivo, 
					fecha_hora_carga_tabla,					
					fecha_hora_ini_concilia_reg, 
					fecha_hora_fin_concilia_reg,
					fecha_hora_fin_proceso,
					fecha_hora_fin_conadminatm_intercard, 
					transferencia,
					carga,
					conciliacion_inter,
					conciliacion_admin_atm, 
					conciliacion_admin,
					traspaso_historico, 
					num_cargo, 
					monto_cargo,
					num_abono,
					monto_abono, 
					proceso) 
					VALUES( vsNombreArchivo, 'IST', dsFechaArchivo, 0, 0, CURRENT, CURRENT, '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0',
						'1900-01-01 00:00:00.0','1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', '1900-01-01 00:00:00.0', 'V', 'F', 'V', 'V','F','F' ,0, 0, 0, 0, 'P');
			ELSE
			
				EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , 'El archivo de conciliacion STAT06 < ' || vsNombreArchivo || ' > no se puede procesar por el formato.', 'sysconau')
				INTO vCodigo;
				
				LET CODIGO = '00001';
				
			END IF
					
		END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO STAT06 ATM	

		IF CODIGO = '00001' THEN
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Se intento procesar un archivo con formato diferente. Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
				
		ELSE
		
			LET MENSAJE_RPTA = MENSAJE_RPTA || ' Numero de archivos procesados: ' || ( SELECT COUNT(*) FROM bditarjeta:"informix".td_cga_nombre_archivo_atm_stat06 );
			
			EXECUTE PROCEDURE bditarjeta:"informix".sp_cnc_guardabitacora_stat06( 0 , MENSAJE_RPTA, 'sysconau')
			INTO vCodigo;
			LET CODIGO = '00000';
		END IF
		RETURN CODIGO, MENSAJE_RPTA;
	END
END PROCEDURE 
DOCUMENT
'Autor: Miguel Angel Lopez Galvan',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerancia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de obtener el archivo del STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_mueve_archivo_atm_stat06_resp ()

		RETURNING VARCHAR (5)   AS CODIGO, VARCHAR (150) AS MENSAJE_RPTA;
		
		 /*  DEFINICION DE VARIABLES */

			-- CONTROL DE ERRORES
			
		    DEFINE  SQL_ERR          INTEGER;
			DEFINE  ISAM_ERR         INTEGER;
			DEFINE  ERROR_INFO       VARCHAR(80);
			
			--CONTROL GENERAL
			
			DEFINE CODIGO				CHAR (6);
			DEFINE MENSAJE_RPTA			CHAR (80);
			DEFINE vRUTA_STAT06			CHAR (34);
			DEFINE vRuta_Resp			CHAR (44);
			DEFINE vListArchivo			CHAR (20);
			DEFINE vArchiBat			CHAR (20);
			DEFINE vExecuteSQL 			CHAR (300);
			DEFINE vsNombreArchivo 		CHAR (30);
			DEFINE dsFechaArchivo 		CHAR (10);
			
		BEGIN	
			
			ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
			
			  LET CODIGO    = SQL_ERR;
			  LET MENSAJE_RPTA  = ERROR_INFO;
			  
			  RETURN CODIGO, MENSAJE_RPTA;
			  
			END EXCEPTION;
			
			--SET DEBUG FILE TO "/home/c98188925/debug/mov_archivo_dep_atm.out";
			--TRACE ON;
			
				/* INICIALIZACION DE VARIABLES */ --CONTROL GENERAL
				
				LET CODIGO					= '00000';
				LET MENSAJE_RPTA			= 'PROCESO EXITOSO';
				LET vRUTA_STAT06				= '';
				LET vRuta_Resp				= '/home/sysconau/conciliacion/istsw/Respaldo';
				LET vListArchivo			= 'hay_archivos.txt';
				LET vArchiBat				= 'archivos_atm_stat06.bat';
				LET vExecuteSQL				= '';
				LET vsNombreArchivo			= '';
				LET dsFechaArchivo			= '';
				
				
			SET ISOLATION TO dirty READ;
			SET LOCK MODE TO WAIT 3;
			
				SELECT rep_aix
				INTO vRUTA_STAT06
				FROM BdiTarjeta:"informix".td_archivo_origen_atm_stat06
				WHERE archivo_origen='IST';
				

			FOREACH cursor_move FOR	
			
				SELECT nombrearchivo
					INTO vsNombreArchivo
				FROM BdiTarjeta:"informix".td_archivos_conciliacion_atm_stat06
				WHERE fecha_proceso = today 
				AND proceso='T'
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' if  [ -f '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)||' ]; ' ||     
				  ' then ' ||     
					' mv '||TRIM(vRUTA_STAT06)||'/'||TRIM(vsNombreArchivo)|| ' ' ||vRuta_Resp||';'||  
				 ' fi  >' ||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				 SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = ' chmod 777 '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
				
				LET vExecuteSQL  = '';
				LET vExecuteSQL  = 'rm -f '||TRIM(vRUTA_STAT06)||'/'||vArchiBat;
				SYSTEM vExecuteSQL;
	

			END FOREACH; -- CICLO DE OBTENCION DE REGISTROS DEL NOMBRE DEL ARCHIVO DE MASTER CARD
			
			RETURN CODIGO, MENSAJE_RPTA;
		END
	END PROCEDURE
	DOCUMENT
'Autor: Maria Fernanda Ortiz Figueroa',
'Proyecto: Optimizacion Conciliacion Automatica - Separacion STAT06',
'Solicito: Gerencia de Produccion y Base de Datos Centrales',
'Descripcion: Proceso que se encarga de realizar el respaldo del archivo de la conciliacion de ATM STAT06',
'Fecha: 2023/12/13',
'Version: 1.0',
'BD: BdiTarjeta';

CREATE PROCEDURE "informix".sp_carga_buen_fin_cnc(vArchivoDBLOAD CHAR(100), RUTA CHAR(100))

	RETURNING CHAR(5) AS CodigoRetorno, CHAR(160) AS mensaje;
	
	-- Define Var Init Var Control 
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE nomArch              VARCHAR(100);
	DEFINE nomRut		    	VARCHAR(100);
	
	-- Define Var EXCEPTION
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Init Var Control
	LET nomRut = TRIM(RUTA);
	LET nomArch = vArchivoDBLOAD;
	LET vIntervaloCommit = 1000;
	LET vExecuteSQL	='';
	LET vNombreCompTXT = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.txt";
	LET vNombreCompLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023_log.log";
	LET vNombreEjecucionLog = TRIM(nomRut) || "/extraccion_tbl_bf_movs_cnc_sorteo_2023.log";
	
	-- Init Var Exception
	LET vCodigoRetorno = '00000';
	LET vMensaje = '';
	LET SQLERR	 = 0;
    LET ISAM_ERR = 0;
    LET ERROR_INFO = '';
	
	
	BEGIN 
		-- Flujo de Excepciones
		ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
					
			SET DEBUG FILE TO RUTA || "carga_.err.out";
			TRACE ON;
			
			IF ( SQLERR <> 0 ) THEN
				LET vCodigoRetorno = SQLERR;
				LET vMensaje = ERROR_INFO;                
				RETURN vCodigoRetorno, vMensaje;
			END IF;
					
		END EXCEPTION;
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--Termina Flujo de Exepciones 			
		
		-- Comienza Load de archivo 
		LET vCodigoRetorno = '00001';        
		LET vMensaje = 'GENERAR COMANDO DE CARGA.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(nomRut) || '/' || TRIM(nomArch)|| "' delimiter '"|| '|' ||"' "|| '17'||
					"; INSERT INTO "|| 'tbl_bf_movs_cnc_sorteo' || ";"||'"'||' > '|| vNombreCompTXT;
		SYSTEM vExecuteSQL;
		
		LET vCodigoRetorno = '00002';        
		LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
		
		LET vExecuteSQL = '';
		LET vExecuteSQL = "dbload -d bditarjeta -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
		SYSTEM vExecuteSQL; 
		
		LET vCodigoRetorno = '00000';        
		LET vMensaje = 'ARCHIVO CARGADO';

		RETURN vCodigoRetorno, vMensaje;
	END;
END PROCEDURE;