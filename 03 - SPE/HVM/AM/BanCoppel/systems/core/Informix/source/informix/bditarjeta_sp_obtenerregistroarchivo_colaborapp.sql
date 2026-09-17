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