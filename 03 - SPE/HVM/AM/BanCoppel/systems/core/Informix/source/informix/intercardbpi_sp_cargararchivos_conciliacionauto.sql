CREATE PROCEDURE "informix".sp_cargararchivos_conciliacionauto( psArchivoOrigen CHAR(3), psNombreArchivo CHAR(30) )

RETURNING INTEGER AS Retorno, INTEGER AS NumRegistros ;

--****************************************************************************************************
-- DESCRIPCION:  TOMA LA INFORMACION SIGNIFICATIVA DE CADA REGISTRO ( SEGUN EL STAT AL QUE PERTENESCA ) E INSERTA ESTA INFORMACION EN LA TABLA CORRESPONDIENTE
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 20/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 22/04/2010 Casanova Edeza Hector Juan.  Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS. 
-- SISTEMA : Conciliacion Intercard -- Transferencia de prestamos
-- MODIFICADO : 25/05/2011 ALFONSO ANTONIO CRUZ ALVAREZ.  Se modifico el flujo para que contemple los nuevos archivos archivos de transferencia de prestamos (TPD) se manejan como archivos de POS. 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viTotalRegistros INTEGER ;
DEFINE vsRegistroATM CHAR (601) ; --- 325 cambio por bambio de cadena 
DEFINE vsRegistroPOS CHAR (325) ;
DEFINE vsMonto CHAR (11) ;
DEFINE vsFlagEnTransaccion CHAR (1);
DEFINE viContadorRegistros INTEGER;

DEFINE visqlerr INTEGER ;
DEFINE viAux INTEGER;

/* INICIALIZACION DE VARIABLES */
LET viTotalRegistros = 0 ;
LET vsRegistroATM = '' ;
LET vsRegistroPOS = '' ;
LET vsMonto = '' ;
LET vsFlagEnTransaccion = '';
LET viContadorRegistros = 0;


LET visqlerr = 0;
LET viAux = 0;

BEGIN

       ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
	IF visqlerr <> 0 THEN             
			
			-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
			IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
			END IF;
			
			
			EXECUTE PROCEDURE Intercard:"informix".sp_Insertar_Bitacora( 'CONAUT', psArchivoOrigen, 'CARGA ARCHIVOS' , 'ERROR DE INFORMIX NO CONTROLADO (' || visqlerr || ')') INTO visqlerr ;
			DELETE FROM intercard:Conciliacion_ATM_IN where ArchivoOrigen = psArchivoOrigen;
                        DELETE FROM intercard:Conciliacion_POS_IN where ArchivoOrigen = psArchivoOrigen;
			
			RETURN visqlerr, viTotalRegistros;
			
		END IF; 
	END EXCEPTION;

	ON EXCEPTION IN (-535)
		EXECUTE PROCEDURE Intercard:"informix".sp_Insertar_Bitacora ( '00000', '000',  'sp_cargararchivos_conciliacionauto', 'ERROR (-535) SE DEJO UNA TRANSACCION HABIERTA EN OTRO PROCESO.' ) INTO viAux; 
		LET vsFlagEnTransaccion = 'V';
	END EXCEPTION WITH RESUME;
		
--SET DEBUG FILE TO '/informix/HomeInformix/rrm/cargararchivos.txt';
--TRACE ON;
		
	--OBTIENE EL NUMERO DE REGISTROS EN LA TABLA
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	SELECT COUNT(Registro) INTO viTotalRegistros FROM intercard:Archivos_Conciliacion;


	--INDICA A QUE TABLA CORRESPONDEN LOS REGISTROS 
	IF ( ( psArchivoOrigen = 'TMC' ) OR ( psArchivoOrigen = 'TMD' ) ) THEN --ATM  ( STAT 07 )  EGLOBAL

		--BORRA LOS REGISTROS DEL MISMO TIPO EN LA TABLA DESTINO
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		DELETE FROM intercard:Conciliacion_ATM_IN where ArchivoOrigen = psArchivoOrigen;

		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM archivos_conciliacion
		FOREACH WITH HOLD
		SELECT Registro INTO vsRegistroATM FROM intercard:archivos_conciliacion
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET vsMonto = '' ; --EGLOBAL 183
			LET vsMonto = TRIM(SUBSTRING (vsRegistroATM FROM 183 FOR 8 )) || '.' || TRIM(SUBSTRING (vsRegistroATM FROM 191 FOR 2));  --MONTO
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO intercard:Conciliacion_ATM_IN
			(FechaConciliacion, ArchivoOrigen, SecuenciaAuth, NumTarjeta, Fecha, Hora, Conciliado, Adquiriente, 
			NumCuenta, Descripcion, IndicadordeReversa, CodigoIso, SecuenciaCajero, Monto, Numcajero, 
			Resp, Orden, Red, Dolares, NumAutorizacion, CodPais, MontoOrigen, CodMoneda, MontoSurcharge, 
			Donativo, Empresa, Compania, Monto_LoyaltyFee, Monto_UsoLinea, NomBancoEmisor, BanderaAdquiriente)
			VALUES
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistroATM FROM 10 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 16 )),  --NUMTARJETA
				TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 )),  --FECHA
				TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 )),  --HORA
				'F', --CONCILIADO
				TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 )),  --ADQUIRIENTE
				TRIM(SUBSTRING (vsRegistroATM FROM 48 FOR 20 )),  --NUMCUENTA
				TRIM(SUBSTRING (vsRegistroATM FROM 91 FOR 15 )),  --DESCRIPCION
				TRIM(SUBSTRING (vsRegistroATM FROM 70 FOR 19 )),  --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistroATM FROM 115 FOR 3 )),  --CODIGOISO
				TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 12 )),  --SECUENCIACAJERO
				TRIM(vsMonto),  --MONTO
				TRIM(SUBSTRING (vsRegistroATM FROM 136 FOR 14 )), -- NUMCAJERO     14  PRO 10
				--NUEVO
				TRIM(SUBSTRING (vsRegistroATM FROM 109 FOR 6 )), -- RESP
				TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 6 )), -- ORDEN
				TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 7 )), -- RED
				TRIM(SUBSTRING (vsRegistroATM FROM 193 FOR 7 )), -- DOLARES
				'', -- NUMAUTORIZACION
				'', -- CODPAIS
				'', -- MONTOORIGEN
				'', -- CODMONEDA
				--TRIM(SUBSTRING (vsRegistroATM FROM 200 FOR 10 )), -- MONTOSURCHARGE
				TRIM(SUBSTRING (vsRegistroATM FROM 200 FOR 8 )) || '.' || TRIM(SUBSTRING (vsRegistroATM FROM 208 FOR 2)),  --MONTOSURCHARGE
				0.0, -- DONATIVO
				'', -- EMPRESA
				'', -- COMPAÑIA
				--TRIM(SUBSTRING (vsRegistroATM FROM 210 FOR 10 )), -- MONTO_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistroATM FROM 210 FOR 8 )) || '.' || TRIM(SUBSTRING (vsRegistroATM FROM 218 FOR 2)),  --MONTO_LOYALTYFEE
				0.0, -- MONTO_USOLINEA
				TRIM(SUBSTRING (vsRegistroATM FROM 220 FOR 20 )), -- NOMBANCOEMISOR
				TRIM(SUBSTRING (vsRegistroATM FROM 240 FOR 1 )) -- BANDERAADQUIRIENTE
			);
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
	
	--INDICA A QUE TABLA CORRESPONDEN LOS REGISTROS 
	ELIF ( psArchivoOrigen = 'TMP' ) THEN --ATM  ( STAT 07 )  PROSA
		--BORRA LOS REGISTROS DEL MISMO TIPO EN LA TABLA DESTINO
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		DELETE FROM intercard:Conciliacion_ATM_IN where ArchivoOrigen = psArchivoOrigen;
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM archivos_conciliacion
		FOREACH WITH HOLD
		SELECT Registro INTO vsRegistroATM FROM archivos_conciliacion
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			LET vsMonto = '' ;
			
			--ATM  PROPIOS  --prosa  181
			LET vsMonto = TRIM(SUBSTRING (vsRegistroATM FROM 181 FOR 10 )) ;  --MONTO
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO intercard:Conciliacion_ATM_IN
			(FechaConciliacion, ArchivoOrigen, SecuenciaAuth, NumTarjeta, Fecha, Hora, Conciliado, Adquiriente, 
			NumCuenta, Descripcion, IndicadordeReversa, CodigoIso, SecuenciaCajero, Monto, Numcajero, 
			Resp, Orden, Red, Dolares, NumAutorizacion, CodPais, MontoOrigen, CodMoneda, MontoSurcharge, 
			Donativo, Empresa, Compania, Monto_LoyaltyFee, Monto_UsoLinea, NomBancoEmisor, BanderaAdquiriente)
			VALUES
			(
				CURRENT,
				psArchivoOrigen,
				TRIM(SUBSTRING (vsRegistroATM FROM 10 FOR 6 )), --SECUENCIAAUTH 
				TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 16 )),  --NUMTARJETA
				TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 )),  --FECHA
				TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 )),  --HORA
				'F', --CONCILIADO
				TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 )),  --ADQUIRIENTE
				TRIM(SUBSTRING (vsRegistroATM FROM 48 FOR 20 )),  --NUMCUENTA
				TRIM(SUBSTRING (vsRegistroATM FROM 91 FOR 15 )),  --DESCRIPCION
				TRIM(SUBSTRING (vsRegistroATM FROM 70 FOR 19 )),  --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistroATM FROM 116 FOR 2 )),  --CODIGOISO      --cambiar a 116 y for a 2 
				TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 12 )),  --SECUENCIACAJERO
				TRIM(vsMonto),  --MONTO
				TRIM(SUBSTRING (vsRegistroATM FROM 136 FOR 10 )), -- NUMCAJERO     10  EG 14
				--NUEVO
				TRIM(SUBSTRING (vsRegistroATM FROM 109 FOR 2 )), -- RESP
				TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 4 )), -- ORDEN
				TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 4 )), -- RED
				TRIM(SUBSTRING (vsRegistroATM FROM 192 FOR 7 )), -- DOLARES
				TRIM(SUBSTRING (vsRegistroATM FROM 201 FOR 6 )), -- NUMAUTORIZACION
				TRIM(SUBSTRING (vsRegistroATM FROM 209 FOR 2 )), -- CODPAIS
				TRIM(SUBSTRING (vsRegistroATM FROM 213 FOR 13 )), -- MONTOORIGEN
				TRIM(SUBSTRING (vsRegistroATM FROM 228 FOR 3 )), -- CODMONEDA
				TRIM(SUBSTRING (vsRegistroATM FROM 233 FOR 10 )), -- MONTOSURCHARGE
				TRIM(SUBSTRING (vsRegistroATM FROM 245 FOR 10 )), -- DONATIVO
				TRIM(SUBSTRING (vsRegistroATM FROM 257 FOR 4 )), -- EMPRESA
				TRIM(SUBSTRING (vsRegistroATM FROM 262 FOR 10 )), -- COMPAÑIA
				TRIM(SUBSTRING (vsRegistroATM FROM 273 FOR 10 )), -- MONTO_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistroATM FROM 284 FOR 10 )), -- MONTO_USOLINEA
				'', -- NOMBANCOEMISOR
				'' -- BANDERAADQUIRIENTE
			);
			
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;

		END FOREACH;
		
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
	ELIF ( ( psArchivoOrigen = 'VNC' ) OR ( psArchivoOrigen = 'VND' ) OR ( psArchivoOrigen = 'VIC' ) OR ( psArchivoOrigen = 'VID' ) OR 
			( psArchivoOrigen = 'PNC' ) OR ( psArchivoOrigen = 'TCC' ) OR ( psArchivoOrigen = 'TCD' ) OR
			( psArchivoOrigen = 'CCP' ) OR ( psArchivoOrigen = 'CCD' ) OR
			( psArchivoOrigen = 'TPD') ) THEN --POS     ( STAT 325 )
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		DELETE FROM intercard:Conciliacion_POS_IN where ArchivoOrigen = psArchivoOrigen;
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		FOREACH WITH HOLD
		SELECT Registro INTO vsRegistroPOS FROM intercard:Archivos_Conciliacion
			
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO intercard:Conciliacion_POS_IN(fechaconciliacion, archivoorigen, secuenciaauth, numtarjeta, fecha, GiroNegocio, 
						 tipotransaccion, monto, montocashback, idcomercio, nomcomercio, reftransaccion, rfc, fuenteid, moneda, Divisa, 
						 MontoDivisa, FormadePago, conciliado)
				VALUES (
					CURRENT,
					psArchivoOrigen,                        
					TRIM(SUBSTRING (vsRegistroPOS FROM 210 FOR 6 )),  --SECUENCIAAUTH
					TRIM(SUBSTRING (vsRegistroPOS FROM 5 FOR 16 )),  --NUMTARJETA
					TRIM(SUBSTRING (vsRegistroPOS FROM 234 FOR 6 )), --FECHA
					TRIM(SUBSTRING (vsRegistroPOS FROM 166 FOR 4 )), --GIRONEGOCIO
					TRIM(SUBSTRING (vsRegistroPOS FROM 37 FOR 2 )),  --TIPOTRANSACCION
					TRIM(SUBSTRING (vsRegistroPOS FROM 39 FOR 11 )) || '.' || TRIM(SUBSTRING (vsRegistroPOS FROM 50 FOR 2)), --MONTO
					TRIM(SUBSTRING (vsRegistroPOS FROM 52 FOR 11 )) || '.' || TRIM(SUBSTRING (vsRegistroPOS FROM 63 FOR 2)),  --MONTOCASHBACK
					TRIM(SUBSTRING (vsRegistroPOS FROM 95 FOR 9 )),  --IDCOMERCIO
					TRIM(SUBSTRING (vsRegistroPOS FROM 104 FOR 30 )),  --NOMCOMERCIO
					TRIM(SUBSTRING (vsRegistroPOS FROM 142 FOR 23 )),  --REFTRANSACCION
					TRIM(SUBSTRING (vsRegistroPOS FROM 216 FOR 16 )),  --RFC
					TRIM(SUBSTRING (vsRegistroPOS FROM 250 FOR 3 )),  --FUENTEID
					'01', --MONEDA
					TRIM(SUBSTRING (vsRegistroPOS FROM 309 FOR 3 )), --DIVISA
					TRIM(SUBSTRING (vsRegistroPOS FROM 292 FOR 9 )) || '.' || TRIM(SUBSTRING (vsRegistroPOS FROM 301 FOR 2)),  --MONTODIVISA
					TRIM(SUBSTRING (vsRegistroPOS FROM 78 FOR 1 )), --FORMADEPAGO
					'F');  --CONCILIADO
				
			LET viContadorRegistros = viContadorRegistros + 1;
				
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLEQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
		
	ELIF ( ( psArchivoOrigen = 'TMO' ) ) THEN --ATM OTROS ( STAT 06 )
		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM Archivos_Conciliacion
		FOREACH WITH HOLD
		SELECT Registro INTO vsRegistroATM FROM intercard:Archivos_Conciliacion
				
				
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			INSERT INTO intercard:Conciliacion_ATM_Stat06 ( FechaConciliacion, ArchivoOrigen, NombreArchivo, Emisor, NumCajero, NumTarjeta, NumCuenta, 
			IndicadordeReversa, Descripcion, Respuesta, CodigoISO, Secuencia, Fecha, Hora, Orden, Red, Monto, Dolares, 
			ComisionSurcharge, Donativo, Emp, Autorizacion, Compania, Comision_LoyaltyFee, Comision_UsoLinea)
			VALUES (
				CURRENT,
				psArchivoOrigen,
				TRIM(psNombreArchivo),
				TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 )), --EMISOR
				TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 12 )), --NUMCANERO
				TRIM(SUBSTRING (vsRegistroATM FROM 37 FOR 16 )), -- NUMTARJETA
				TRIM(SUBSTRING (vsRegistroATM FROM 60 FOR 20 )), --NUMCUENTA
				TRIM(SUBSTRING (vsRegistroATM FROM 82 FOR 19 )), --INDICADORDEREVERSA
				TRIM(SUBSTRING (vsRegistroATM FROM 103 FOR 15 )), --DESCRIPCION
				TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 6 )), --RESPUESTA
				TRIM(SUBSTRING (vsRegistroATM FROM 128 FOR 2 )), --CODIGOISO     CAMBIARA 128 PARA QUE TOME POSICIONES CORRECTAS DE CODIGO ISO
				TRIM(SUBSTRING (vsRegistroATM FROM 133 FOR 12 )), --SECUENCIA
				TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 )), --FECHA
				TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 )), --HORA
				TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 6 )), --ORDEN
				TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 4 )), --RED 
				TRIM(SUBSTRING (vsRegistroATM FROM 181 FOR 10 )),  --MONTO
				TRIM(SUBSTRING (vsRegistroATM FROM 192 FOR 7 )),  --DOLARES
				--NUEVO
				TRIM(SUBSTRING (vsRegistroATM FROM 200 FOR 10 )),  --COMISIONSURCHARGE
				TRIM(SUBSTRING (vsRegistroATM FROM 211 FOR 10 )),  --DONATIVO
				TRIM(SUBSTRING (vsRegistroATM FROM 222 FOR 4 )),  --EMP
				TRIM(SUBSTRING (vsRegistroATM FROM 227 FOR 6 )),  --AUTORIZACION
				TRIM(SUBSTRING (vsRegistroATM FROM 234 FOR 10 )), --COMPAÑIA
				TRIM(SUBSTRING (vsRegistroATM FROM 245 FOR 10 )),  --COMISION_LOYALTYFEE
				TRIM(SUBSTRING (vsRegistroATM FROM 256 FOR 10 ))  --COMISION_USOLINEA
				);
					
			LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
				COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
				CONTINUE FOREACH;
			END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
-- Para agregar Nuevo Archivo REDTCAT137D
	ELIF ( ( psArchivoOrigen = 'TMS' ) ) THEN 		
		LET vsFlagEnTransaccion = 'F';
		LET viContadorRegistros = 0;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM Archivos_Conciliacion
		FOREACH WITH HOLD
		SELECT Registro INTO vsRegistroATM FROM intercard:Archivos_Conciliacion
			--ACTIVA EL BLOQUE DE REGISTROS POR TRANSACCION
			IF (vsFlagEnTransaccion = 'F') THEN 
				 BEGIN WORK;
				 LET vsFlagEnTransaccion = 'V';
			END IF;
			
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		INSERT INTO intercard:conciliacion_redtcat137d (
													keyx,
													FechaConciliacion,
													archivoorigen,
													nombrearchivo,
													fiid,
													codatm,
													count1,
													count2,
													count3,
													count4,
													count5,
													count6,
													totaloutdolares,
													tlfdolares,
													difdolares,
													totaloutmonlocal,
													tlfmonedalocal,
													diferenmon,
													end1,
													end2,
													end3,
													end4,
													end5,
													end6,
													remanentedolares,
													remanentelocal,
													denomc1,
													cdec1,
													denomc2,
													cdec2,
													denomc3,
													cdec3,
													denomc4,
													cdec4,
													denomc5,
													cdec5,
													denomc6,
													cdec6,
													fechainicial,
													fechafinal,
													tipocorte)
		VALUES (
				0,
				CURRENT,
				psArchivoOrigen,
				psNombreArchivo,
				TRIM(SUBSTRING (vsRegistroATM FROM 2 FOR 4 )),  		--EMISOR
				TRIM(SUBSTRING (vsRegistroATM FROM 15 FOR 5 )),  		--CAJERO
				TRIM(SUBSTRING (vsRegistroATM FROM 31 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 52 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 73 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 94 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 115 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 136 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 157 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 178 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 199 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 220 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 241 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 262 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 283 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 304 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 325 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 346 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 367 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 388 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 409 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 430 FOR 10 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 447 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 455 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 466 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 474 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 485 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 493 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 504 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 512 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 523 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 531 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 542 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 550 FOR 4 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 556 FOR 15 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 573 FOR 15 )),
				TRIM(SUBSTRING (vsRegistroATM FROM 595 FOR 4 ))
				);
			
		LET viContadorRegistros = viContadorRegistros + 1;
			
			--TERMINA EL BLOQUE DE REGISTROS POR TRANSACCION
		IF (viContadorRegistros = 1000) THEN --VERIFICA SI ALCANSO EL MAXIMO DE TRANSACCIONES POR BLOQUE
			COMMIT WORK;
				LET vsFlagEnTransaccion = 'F';
				LET viContadorRegistros = 0;
			CONTINUE FOREACH;
		END IF;
			
		END FOREACH;
		
		-- TERMINA EL ULTIMO BLOQUE DE TRANSACCION PENDIENTE.
		IF ((viContadorRegistros > 0) OR (vsFlagEnTransaccion = 'V')) THEN --VERIFICA SI EXISTE UN BLOQUE DE TRANSACCION PENDIENTE
			COMMIT WORK;
			LET vsFlagEnTransaccion = 'F';
			LET viContadorRegistros = 0;
		END IF;
	ELSE -- NINGUNO DE LOS CASOS            
		LET visqlerr = 3 ;
	END IF ;
	
	
	--BORRA LOS REGISTROS DE Archivos_Conciliacion  ---- YA NO SON UTILES
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	DELETE FROM intercard:archivos_conciliacion;
	
	RETURN visqlerr, viTotalRegistros ;
	
END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: TOMA LA INFORMACION SIGNIFICATIVA DE CADA REGISTRO ( SEGUN EL STAT AL QUE PERTENESCA ) E INSERTA ESTA INFORMACION EN LA TABLA CORRESPONDIENTE.',
'Fecha: 2008/08/20',
'Version: 20080820.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 21 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1127',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico la posicion de consulta de los datos significativos del archivo para los ATM.',
'Fecha: 2010/04/14',
'Version: 20100414.1304',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS.',
'Fecha: 2010/04/22',
'Version: 20100422.1222',
'BD: Intercard',
'',
'Modificado: Alfonso Antonio Cruz Alvarez',
'Proyecto: Conciliacion Automatica -- Transferencia de prestamos',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de transferencia de prestamos (TPD) se manejan como archivos de POS.',
'Fecha: 2011/05/25',
'Version: 20110525.0949',
'BD: Intercard'
'',
'Modificado: Reséndiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica -- Integracion de Archivo REDTCAT137DYYMMDDEDCC.DAT',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego Proceso para la integracion del Archivo REDTCAT137DYYMMDDEDCC.DAT y se modifico la variable de NombreArchivo a 30 caracteres.',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard'
*/;

CREATE PROCEDURE "informix".sp_conciliacion_pos_registro(
psNumEmpleado CHAR (8),
psArchivoOrigen CHAR (3),
psActividad CHAR (25),
psUsuarioParametros CHAR (8),
psFecha CHAR (8),
psGiroNegocio CHAR (4), 
psFuenteId CHAR (3),
psIdComercio CHAR (9),
psMoneda CHAR (3),
pmMonto MONEY,
pmMontoCashBack MONEY,
psNomComercio CHAR (30),
psNumTarjeta CHAR (16),
psRefTransaccion CHAR (23),
psRFC CHAR (16),
psSecuenciaAuth CHAR (6),
psTipoTransaccion CHAR (2),
psDivisa CHAR (3), 
pmMontoDivisa MONEY, 
psFormadePago CHAR (1)
)

RETURNING INTEGER, CHAR (500) ;

--****************************************************************************************************
-- DESCRIPCION: PROCESO DE CONCILIACION A UN REGISTROS EN ESPECIFICO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 01/07/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO :  Casanova Edeza Hector Juan   -- ZERO  
-- MODIFICADO : 05/11/2009 --Casanova Edeza Hector Juan.
-- MODIFICADO :  Jacqueline Dominguez -- Folio Extendido
-- MODIFICADO : 14/04/2010 --Jacqueline Dominguez.
-- MODIFICADO :  Casanova Edeza Hector Juan 2011/10/24 --SE ELIMINA EL CODIGO QUE ESTABLECE TODAS LAS DEVOLUCIONES COMO NO ENCONTRADAS EN INTERCAD, PARA SU TRATAMIENTO NORMAL
-- MODIFICADO :  Casanova Edeza Hector Juan 2011/11/28 --SE PASA EL VALOR DEL CAMPO MOVCONCILIADO DEL REGISTRO DE DEVOLUCION ACTUAL AL SP_CLASIFICA_DEVOLUCIONES_POS.
-- MODIFICADO :  Casanova Edeza Hector Juan 2011/12/15 --SE AGREGA EL PARAMETRO DE FECHAAUTORIZACION AL SP DE CLASIFICACION DE DEVOLUCIONES.
--***************************************************************************************************

DEFINE vsmensajeError CHAR (500) ;
DEFINE viStatusConciliacion INTEGER ;
--CHECAR LO DE LA REFRENCIA
DEFINE vsReferencia CHAR (40) ;

DEFINE vsDESCRIPCION1 CHAR (100) ;
DEFINE vsDESCRIPCION2 CHAR (100) ;
DEFINE vsDESCRIPCION3 CHAR (200) ;

DEFINE vsQUERY1 CHAR (800) ;   --SELECT DE MOVIMIENTO
DEFINE vsQUERY2 CHAR (350) ;    --INSERT DE  REVERZAFORDADA
DEFINE vsQUERY3 CHAR (2000) ;    --INSERT DE


DEFINE vsREGISTROCENTRAL1 CHAR (300) ;
DEFINE vsREGISTROCENTRAL2 CHAR (300) ;

/*  DEFINICION DE VARIABLES */

DEFINE pmMontoRetenido MONEY ;

DEFINE vsHora CHAR (8) ;
DEFINE vsRegistrado  CHAR (1) ;
DEFINE vsCodRespBASE24 CHAR (3) ;
DEFINE vsCodTran  CHAR (2) ;
DEFINE vsProdInd CHAR (2) ;
DEFINE vsFormato CHAR (4) ;

DEFINE vsNumCuenta CHAR (13) ;
DEFINE vsTipoEnviadaCentral CHAR (1) ;
DEFINE vsClaveAutorizacionDeTransaccion CHAR (7) ;
DEFINE vsNacional CHAR (1) ;
DEFINE viTipodeTransaccion INTEGER ;
DEFINE vsTipoTran CHAR (2) ;



--- VARIABLES DEL SELECT DE MOVIMIENTOS
DEFINE vsMovSecuencia CHAR (7) ;    --ClaveAutorizacionDeTransaccion
DEFINE vsMovSecuenciaExtendida CHAR (16) ; --ClaveAutorizacionDeTransaccionExtendida
DEFINE vsMovCodigoISO CHAR (2) ;
DEFINE vmMovMonto  MONEY ;
DEFINE vsMovMovConciliado  CHAR (1) ;
DEFINE vsMovMovReversado CHAR (1) ;
DEFINE vsMovFechaMov CHAR (4) ;
DEFINE vsMovCodigoCentral CHAR (5) ;
DEFINE vsMovSecuenciaOrig CHAR (7) ;
DEFINE vsMovHoraMov CHAR (6) ;
DEFINE vsMovCodReversa CHAR (1) ;
DEFINE vmMovMontoRealRevFzda MONEY ;
DEFINE vsMovIdTerminal CHAR (16) ;
DEFINE vsMovEnLinea CHAR (1) ;
DEFINE vsMovEsNacional CHAR (1) ;
DEFINE vsMovFechaLocalTransaccion CHAR (4) ;
DEFINE vsMovHoraLocalTransaccion CHAR (6) ;
DEFINE vsMovPermiteComisionPendiente CHAR (1) ;
DEFINE vsMovGeneroComisionPendiente CHAR (1) ;
DEFINE vsMovSecComision CHAR (7) ;
DEFINE vsMovComisionEnLinea CHAR (1) ;
DEFINE vmMovMontoComision MONEY ;
DEFINE vsMovCodigoRetComision CHAR (5) ;
DEFINE vmMovMontoSurcharge MONEY ;
DEFINE vsMovSecSurcharge CHAR (7) ;
DEFINE vsMovIdComercio CHAR (10) ;
DEFINE vmMovMontoCashBack  MONEY ;
DEFINE vmMovMontoComCashBack  MONEY ;
DEFINE vmMovMontoRetenido MONEY ;
DEFINE vsMovMoneda CHAR (3) ;
DEFINE vsMovSecuenciaCashBack  CHAR (7) ;
DEFINE vsMovSecuenciaComCashBack CHAR (7) ;
DEFINE vsMovIdReceptor CHAR (4) ;
DEFINE vsMovCodTran CHAR (2) ;
DEFINE vsMovFormato CHAR (4) ;

DEFINE viStatusConSurcharge     INTEGER ;
DEFINE vsStatusComision CHAR (1) ;

DEFINE viExisteEnMovimiento INTEGER ;

--SELECT DE REVERZA O FORZADA
DEFINE viExisteReverzaForzada INTEGER ;
DEFINE vsRFSecuencia CHAR (7) ;
DEFINE vsRFCodigoISO CHAR (2) ;
DEFINE vsRFFechaMov CHAR (4) ;
DEFINE vmRFMonto MONEY ;
DEFINE vmRFMontoCashBack MONEY ;
DEFINE vmRFMontoRealRevFzda MONEY ;
DEFINE vsRFCodTran CHAR (2) ;
DEFINE vsRFFormato CHAR (4) ;
DEFINE vsRFMovConciliado CHAR (1) ;
DEFINE vsRFIdTerminal CHAR (16) ;
DEFINE vsRFEnLinea CHAR (1) ;
DEFINE vsRFHoraLocalTransaccion CHAR (6) ;
DEFINE vsRFMovReversado CHAR (1) ;
DEFINE vsRFCodReversa CHAR (1) ;
DEFINE vsRFCodigoCentral CHAR (5) ;


DEFINE vsEnLinea CHAR (1) ;
DEFINE vsIdTerminal CHAR (8) ;
DEFINE vsIdReceptor CHAR (4) ;
DEFINE vsSecEnviadaCentral CHAR (7) ;
DEFINE vsStatusTarjeta CHAR (3) ;
DEFINE vsHoraLocalTransaccion CHAR (6) ;
DEFINE pmMontoTran MONEY ;
DEFINE vdtMovFechaHoraInAuthorizer DATETIME YEAR TO FRACTION ;
DEFINE psFechaLocalTransaccion CHAR (4) ;

DEFINE vsCodRet CHAR (5) ;
DEFINE vsCodRetSurcharge CHAR (5) ;
DEFINE psFechaAplib DATETIME YEAR TO FRACTION ;
DEFINE psFechaReporteBreve DATETIME YEAR TO FRACTION ;
DEFINE vsEsConvenio CHAR (1) ;
DEFINE vsEspropio CHAR (1) ;
DEFINE vsTipoRecibidaCentral     CHAR (1) ;
DEFINE vsTnrCobroComisionCtaIndividual  CHAR (1) ;
DEFINE vmTnrMontoComisionCtaIndividual MONEY ;

DEFINE pmMontoReversa MONEY ;
DEFINE vsTipoConciliacion CHAR (2) ;

DEFINE vsTipoTransInterEmpresa CHAR (4) ;
DEFINE vmMontoComInterEmpresa MONEY ;
DEFINE vsConvenioInterEmpresa CHAR (10) ;

--VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr   INTEGER ;
DEFINE viCodRet   INTEGER ;

DEFINE vsTransaccionOrigen CHAR (4);
DEFINE vsNomArchivo VARCHAR(30);
/* INICIALIZACION DE VARIABLES */

LET vsmensajeError = '' ;
LET viStatusConciliacion = 0 ;
LET vsReferencia = '' ;

--VARIABLES LOG
LET vsDESCRIPCION1 = '' ;
LET vsDESCRIPCION2 = '' ;
LET vsDESCRIPCION3 = '' ;

LET vsQUERY1 = '' ;
LET vsQUERY2 = '' ;
LET vsQUERY3 = '' ;

LET vsREGISTROCENTRAL1 = '' ;
LET vsREGISTROCENTRAL2 = '' ;

--DATOS DE LA TABLA CONCILIACION _POS_IN

LET vsHora  = '' ;
LET vsCodRespBASE24 = '' ;

LET vsCodTran  = '00' ;
LET vsProdInd = '02' ;
LET vsFormato = '0200' ;
LET vsRegistrado = 'F' ;
LET psFuenteId = '000' ;


LET vsNumCuenta = '' ;
LET vsTipoEnviadaCentral = '' ;
LET vsClaveAutorizacionDeTransaccion = '' ;
LET vsNacional = '' ;
LET viTipodeTransaccion = 0 ;
LET vsTipoTran = '' ;

--- VARIABLES DEL SELECT DE MOVIMIENTOS
LET vsMovSecuencia = '' ;
LET vsMovSecuenciaExtendida = '';
LET vsMovCodigoISO = '' ;
LET vmMovMonto = 0 ;
LET vsMovMovConciliado = '' ;
LET vsMovMovReversado = '' ;
LET vsMovFechaMov = '' ;
LET vsMovCodigoCentral = '' ;
LET vsMovSecuenciaOrig = '' ;
LET vsMovHoraMov = '' ;
LET vsMovCodReversa = '' ;
LET vmMovMontoRealRevFzda =  0 ;
LET vsMovIdTerminal = '' ;
LET vsMovEnLinea = '' ;
LET vsMovEsNacional = '' ;
LET vsMovFechaLocalTransaccion = '' ;
LET vsMovHoraLocalTransaccion = '' ;
LET vsMovPermiteComisionPendiente = '' ; --F
LET vsMovGeneroComisionPendiente = '' ; --F
LET vsMovSecComision = '' ;
LET vsMovComisionEnLinea = '' ;
LET vmMovMontoComision = 0 ;
LET vsMovCodigoRetComision = '' ;
LET vmMovMontoSurcharge = 0 ;
LET vsMovSecSurcharge = '' ;
LET vsMovIdComercio = '' ;
LET  vmMovMontoCashBack  = 0 ;
LET  vmMovMontoComCashBack  = 0 ;
LET vmMovMontoRetenido = 0 ;
LET vsMovSecuenciaCashBack = '' ;
LET vsMovSecuenciaComCashBack  = '' ;
LET vsMovSecComision   = '' ;
LET vsMovIdReceptor = '' ;
LET vsMovCodTran = '' ;
LET vsMovFormato = '' ;

LET viStatusConSurcharge = 0 ;
LET vsStatusComision = '' ;

LET viExisteEnMovimiento = 0;

--SELECT DE REVERZA O FORZADA
LET viExisteReverzaForzada = 0 ;
LET vsRFSecuencia = '' ;
LET vsRFCodigoISO = '' ;
LET vsRFFechaMov = '' ;
LET vmRFMonto = 0 ;
LET vmRFMontoCashBack = 0 ;
LET vmRFMontoRealRevFzda = 0 ;
LET vsRFCodTran = '' ;
LET vsRFFormato = '' ;
LET vsRFMovConciliado = '' ;
LET vsRFIdTerminal = '' ;
LET vsRFEnLinea = '' ;
LET vsRFHoraLocalTransaccion = '' ;
LET vsRFMovReversado = '' ;
LET vsRFCodReversa = '' ;
LET vsRFCodigoCentral = '' ;

LET vsEnLinea = '' ;
LET vsIdTerminal = '' ;
LET vsIdReceptor = '' ;
LET vsSecEnviadaCentral = '' ;
LET vsStatusTarjeta = '' ;
LET vsHoraLocalTransaccion = '' ;
LET pmMontoTran = 0 ;
LET psFechaReporteBreve = NULL ;
LET vdtMovFechaHoraInAuthorizer = NULL ;
LET psFechaAplib = NULL ;
LET psFechaLocalTransaccion  = '' ;

LET vsCodRet  = '' ;
LET vsCodRetSurcharge = '' ;
LET vsEsConvenio = 'F' ;
LET vsEspropio = 'F' ;
LET vsTipoRecibidaCentral = '' ;
LET  vsTnrCobroComisionCtaIndividual = '' ;
LET vmTnrMontoComisionCtaIndividual = 0 ;
LET pmMontoRetenido = 0 ;
LET pmMontoReversa = 0 ;

LET vsMovMoneda = '' ;
LET vsTipoConciliacion = '' ;

LET vsTipoTransInterEmpresa = '' ;
LET vmMontoComInterEmpresa = 0.0 ;
LET vsConvenioInterEmpresa = '' ;

--VARIABLE DE MANEJO DE ERRORES
LET viCodRet = '0' ;
LET visqlerr = 0 ;

LET vsTransaccionOrigen = '';
LET vsNomArchivo = '';

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN

            EXECUTE PROCEDURE intercard:sp_Insertar_Bitacora ( psNumEmpleado, psArchivoOrigen, psActividad, ' ('|| visqlerr || ')  ' || vsmensajeError ) INTO viCodRet ;

            --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL
            EXECUTE PROCEDURE intercard:sp_Insertar_LOG_POS ( psArchivoOrigen, psNumTarjeta, psTipoTransaccion, pmMonto,
                    pmMontoCashBack, psIdComercio, psNomComercio, psSecuenciaAuth, psRefTransaccion, psRFC,
                    psFuenteId, vsNumCuenta, vsQUERY1, vsMovCodigoISO, vsFormato, vsMovMovConciliado, vsMovFechaMov, vsMovHoraMov,
                    vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraLocalTransaccion, vmMovMontoRealRevFzda, vsCodTran,
                    vsEnLinea, vsIdTerminal, vsProdInd, vsMovSecuenciaCashBack, vsMovSecuenciaComCashBack,
                    vmMovMontoComCashBack, vsMovComisionEnLinea, vsMovPermiteComisionPendiente,
                    vsMovGeneroComisionPendiente, vsMovSecComision, vmMovMontoComision, vsMovCodigoRetComision, vsIdReceptor,
                    vsQUERY2, vsRFCodigoISO, vmRFMonto, vsRFSecuencia, vsRFFechaMov, vsRFEnLinea, vsRFIdTerminal,
                    vsRFHoraLocalTransaccion, vsDESCRIPCION1, vsDESCRIPCION2, vsDESCRIPCION3,vsREGISTROCENTRAL1, vsREGISTROCENTRAL2,
                    vsQUERY3, viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet ;

            RETURN visqlerr , vsmensajeError ;

        END IF;
    END EXCEPTION;


        -- VALORES PREDETERMINADOS PARA ESTOS CAMPOS
        LET pmMontoRetenido = pmMonto ;

        IF ( ( psTipoTransaccion = '20' )  OR ( psTipoTransaccion = '21' ) ) THEN
            LET vsTipoEnviadaCentral = 'A' ;
            LET vsClaveAutorizacionDeTransaccion = '1000000' ;
        END IF ;

        IF ( psTipoTransaccion = '02' ) THEN -- TRANSACCION INTERNACIONAL
			LET psTipoTransaccion='01'; --/// SE CONVIERTE EN TRANSACCION DE COMPRA, YA QUE AUN CUANDO ES RETIRO SE COMPORTA COMO COMPRA CON RETENIDO.
            LET vsNacional = 'F' ;
        ELSE -- TRANSACCION NACIONAL
            LET vsNacional = 'v' ;
        END IF ;

        LET vsmensajeError = 'SELECT NVL( NumCuenta, '' ) INTO vsNumCuenta FROM TarjetaCuenta WHERE NumTarjeta = ' || psNumTarjeta ;
        --OBTIENEN LA CUENTA CORRESPONDIENTE A LA TARJETA
        SET LOCK MODE TO WAIT 3 ;
        SET ISOLATION DIRTY READ ;
        SELECT NVL( NumCuenta, '' ) INTO vsNumCuenta FROM intercard:TarjetaCuenta WHERE NumTarjeta = psNumTarjeta ;

        IF ( vsNumCuenta = '' ) THEN --SI NO SE ENCONTRO CUENTA RELACIONADA A LA TARJETA
            LET vsDESCRIPCION1 =  'Aviso. Transaccion con numero de Cuenta no asociada. NumTarjeta [' || psNumTarjeta || ']' ;
            LET viStatusConciliacion = 7 ;
        ELSE --SI ENCONTRO TARJETA RELACIONADA


            LET vsmensajeError = 'sp_ObtenerDatosTransaccionDBMovimiento_POS ( ' || pmMonto || ', ' || psNumTarjeta || ', ' || psSecuenciaAuth ||')'  ;
            --OBTIENEN LOS DATOS DE LA TRANSACCION DE LA TABLA DE MOVIMIENTO
            EXECUTE PROCEDURE intercard:sp_ObtenerDatosTransaccionDBMovimiento_POS ( pmMonto, psNumTarjeta, psSecuenciaAuth)
                INTO  viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovCodigoISO, vmMovMonto, vsMovMovConciliado,
                vsMovMovReversado, vsMovFechaMov, vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraMov,
                vsMovCodReversa, vmMovMontoRealRevFzda, vsMovIdTerminal, vsMovEnLinea, vsMovEsNacional,
                vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion, vdtMovFechaHoraInAuthorizer, --vsMovFechaHoraInAuthorizer,
                vsMovPermiteComisionPendiente, vsMovGeneroComisionPendiente, vsMovSecComision,
                vsMovComisionEnLinea, vmMovMontoComision, vsMovCodigoRetComision, vmMovMontoSurcharge,
                vsMovSecSurcharge,  vmMovMontoCashBack, vmMovMontoComCashBack, vsMovSecuenciaCashBack,
                vsMovSecuenciaComCashBack, vsMovCodTran, vsmovFormato, vsMovIdReceptor, vsMovMoneda, vsTransaccionOrigen, vsQUERY1 ;

		/*
                IF ( psTipoTransaccion = '20' OR ( psTipoTransaccion = '21' ) ) THEN
                    LET viExisteEnMovimiento = 0 ; --// JCG SE FORZA EXISTENCIA DE MOV EN INTERCARD = 0 PARA TRATARLO CORRECTAMENTE
                    LET vsMovSecuenciaExtendida = NULL;  --// JCG SE IGUALA A NULO SECEXTENDIDA DE MOV EN INTERCARD PARA TRATARLO CORRECTAMENTE
                END IF ;
		*/

                LET vsMovMoneda = '01' ;

                IF ( ( psArchivoOrigen = 'TCC' ) OR ( psArchivoOrigen = 'TCD' ) ) THEN 
                    LET vsmensajeError = 'sp_GetTransaccionInterEmpresas ( "' || psTipoTransaccion|| '", "' || psRFC|| '", ' || pmMonto|| ', ' || pmMonto || ')'  ;
                    EXECUTE PROCEDURE intercard:sp_GetTransaccionInterEmpresas (psTipoTransaccion,  psRFC, pmMonto, pmMontoCashBack ) 
                        INTO vsConvenioInterEmpresa, vsTipoTransInterEmpresa, vmMontoComInterEmpresa ;
                END IF ;
				
				 IF ( viExisteEnMovimiento=3) THEN --/// MARCA CON ERROR A LOS MOVIMIENTOS DE COMPRA QUE NO TIENEN NUMERO DE AUTORIZACIÓN INTERCARD
                    LET vsEnLinea = 'E' ;
                 ELSE
                    LET vsEnLinea = '' ;
                 END IF ;

                --ENCONTRO LA TRANSACCION EN LA TABLA DE MOVIMIENTO
                IF ( viExisteEnMovimiento > 0 ) THEN
                    LET vsRegistrado = 'V' ;

					--Modificacion para proyecto InterRedesidentificacion de campo transaccionorigen para tiendas coppel solicitado por Jose Luis Puebla
					-- Modificacion InterRedes 2009/11/05
					------------------------------------------------------------------------------
					--SET LOCK MODE TO WAIT 3;
					--SET ISOLATION DIRTY READ ;
					--SELECT FIRST 1 TransaccionOrigen INTO vsTransaccionOrigen FROM Movimiento WHERE  Secuencia = '1' || psSecuenciaAuth 
					--AND NumTarjeta = psNumTarjeta AND ProdInd = '02' AND CodGiroNeg = psGiroNegocio;
					------------------------------------------------------------------------------S
					
                    --El movimiento que esta reportando PROSA puede ser una transaccion forzada(ajuste) o una reversa que viene en un dia diferente del que se origino la compra
                    LET vsmensajeError = 'sp_ObtenerReversaoForzada_POS ( "' || vsMovSecuenciaOrig || '", "' || psSecuenciaAuth || '", "' || psNumTarjeta || '" )' ;
                    EXECUTE PROCEDURE intercard:sp_ObtenerReversaoForzada_POS ( vsMovSecuenciaOrig, psSecuenciaAuth, psNumTarjeta )
                    INTO viExisteReverzaForzada, vsRFSecuencia, vsRFCodigoISO, vsRFFechaMov, vmRFMonto, vmRFMontoCashBack, vmRFMontoRealRevFzda,
                    vsRFCodTran, vsRFFormato, vsRFMovConciliado, vsRFIdTerminal, vsRFEnLinea, vsRFHoraLocalTransaccion, vsRFMovReversado,
                    vsRFCodReversa, vsRFCodigoCentral, vsQUERY2 ;

                    IF ( viExisteReverzaForzada > 0 ) THEN
                        LET vsFormato = vsRFFormato ;
                        LET vsCodTran = vsRFCodTran ;
                    ELSE
                        LET vsFormato = vsmovFormato ;
                        LET vsCodTran = vsMovCodTran ;
                    END IF ;

                    IF ( vsMovMovConciliado = 'V' and viExisteEnMovimiento=2) THEN
                        LET vsEnLinea = 'D' ;
                    ELSE
                        LET vsEnLinea = '' ;
                    END IF ;

                    LET vsmensajeError = 'sp_GetTypeOfTransaction( "02", "' || vsFormato || '", "' ||  vsCodTran || '", 0 ,  0 )' ;
                    EXECUTE PROCEDURE intercard:sp_GetTypeOfTransaction( '02', vsFormato , vsCodTran , 0, 0 ) INTO viTipodeTransaccion ;

                    LET vsmensajeError = ' sp_Tipo_Conciliacion_POS( "' ||
                    psUsuarioParametros || '", "' || psArchivoOrigen || '", "' || psNumTarjeta || '", "' ||  vsMovCodigoISO || '", "' ||  psNomComercio || '", "' ||   psRFC  || '", "' ||
                    psSecuenciaAuth || '", ' || pmMonto || ', ' || pmMontoCashBack || ', "' ||  psMoneda || '", "' ||  vsCodTran || '", "' || psRefTransaccion || '", ' ||
                    viExisteEnMovimiento || ', "' ||  vsMovSecuencia || '","' || vsMovSecuenciaExtendida || '", "'  || vsMovMovConciliado || '", "' ||  vsMovMoneda  || '", ' ||  vmMovMonto  || ', ' ||
                    vmMovMontoCashBack  || ', ' || vmMovMontoComision  || ', ' ||  vmMovMontoRealRevFzda || ', "' ||
                    vsMovCodTran || '", "' ||  vsmovFormato || '", "' || vsMovSecuenciaCashBack || '", ' || vmMovMontoComCashBack  || ', "' ||  vsMovSecuenciaComCashBack || '", "' ||
                    vsMovCodigoCentral || '", ' ||
                    viExisteReverzaForzada || ', "' || vsRFCodigoCentral || '", "' ||  vsRFSecuencia || '", "' || vsRFCodigoISO || '", "' ||  vsRFFormato || '", "' ||
                    vsRFCodTran || '", ' ||  vmRFMonto  || ', ' ||  vmRFMontoCashBack  || ', "' ||
                    psTipoTransaccion  || '","' || vsMovFechaLocalTransaccion || '", "' || vsMovHoraLocalTransaccion || ', "' || 
					vsTransaccionOrigen || '" ) ' ;

                    EXECUTE  PROCEDURE intercard:sp_Tipo_Conciliacion_POS(
                    psUsuarioParametros, psArchivoOrigen, psNumTarjeta, vsMovCodigoISO, psNomComercio,  psRFC,
                    psSecuenciaAuth, pmMonto, pmMontoCashBack, psMoneda, vsCodTran, psRefTransaccion,
                    psDivisa, pmMontoDivisa, psFormadePago,
                    viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovMovConciliado, vsMovMoneda, vmMovMonto,
                    vmMovMontoCashBack, vmMovMontoComision, vmMovMontoRealRevFzda,
                    vsMovCodTran, vsmovFormato, vsMovSecuenciaCashBack, vmMovMontoComCashBack, vsMovSecuenciaComCashBack,
                    vsMovCodigoCentral,
                    viExisteReverzaForzada,  vsRFCodigoCentral, vsRFSecuencia, vsRFCodigoISO, vsRFFormato,
                    vsRFCodTran, vmRFMonto, vmRFMontoCashBack,
                    psTipoTransaccion, vsConvenioInterEmpresa, vsTipoTransInterEmpresa, vmMontoComInterEmpresa ,vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion , vsTransaccionOrigen) 
                    INTO vsClaveAutorizacionDeTransaccion, vsMovSecComision, 
                    viStatusConciliacion, vsDESCRIPCION1, vsDESCRIPCION2, vsDESCRIPCION3, vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, 
                    pmMontoReversa, viTipodeTransaccion, vsSecEnviadaCentral, vsMovSecuenciaCashBack, vsMovSecuenciaComCashBack, 
                    vsTipoEnviadaCentral, vsTipoConciliacion ;


                ELSE --TRANSACCION NO REGISTRADA EN INTERCARD
					LET vsTransaccionOrigen = '1234';  --- TransaccionOrigen POR DEFAULT
					
                    LET vsRegistrado = 'F' ;
                    LET vsFormato = '0200' ;

                    LET vsNacional = 'V' ;
                     IF ( ( psTipoTransaccion = '01' ) AND ( pmMonto > 0 ) AND ( pmMontoCashBack = 0) ) THEN
                        LET viTipodeTransaccion = 203 ; --COMPRA_POS
                        LET vsCodTran = '00' ;
                    ELIF ( ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09') AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) ) THEN --HECTOR 04/04/2008
                        LET viTipodeTransaccion = 210 ; --CASHBACK_POS
                        LET vsCodTran = '09' ;
                    ELIF ( ( psTipoTransaccion = '01'  OR psTipoTransaccion = '09' ) AND ( pmMonto > 0 ) AND ( pmMonto = pmMontoCashBack ) ) THEN --HECTOR 04/04/2008
                        LET viTipodeTransaccion = 211 ; --CASHADVANCE_POS
                        LET vsCodTran = '09' ;
                    ELIF ( ( psTipoTransaccion = '21' ) AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) ) THEN
                        LET viTipodeTransaccion = 208 ; --DEVOLUCION_POS
                        LET vsCodTran = '21' ;
                    ELIF ( ( psTipoTransaccion = '02' ) AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) ) THEN
                        ---/// SE AJUSTA PARA QUE EL MOVIMIENTO SEA TRATADO COMO COMPRA, YA QUE EXISTE RETENIDO EN CUENTA.
						/*LET viTipodeTransaccion = 201 ; --RETIRO_ATM
                        LET vsCodTran = '01' ;
                        LET vsNacional = 'F' ;*/
						LET psTipoTransaccion='01';
						LET viTipodeTransaccion = 203 ; --RETIRO_ATM A COMPRA_POS
                        LET vsCodTran = '00' ;
						LET vsNacional = 'F' ;
                    ELIF ( ( psTipoTransaccion = '20' ) AND ( pmMonto > 0 ) AND ( pmMonto > pmMontoCashBack ) ) THEN
                        LET viTipodeTransaccion = 214 ; --PAGO_INTERBANCARIO
                        LET vsCodTran = '20' ;
                    ELSE
                        LET viStatusConciliacion = 7 ;
                    END IF ;

                        LET vsmensajeError = ' sp_Tipo_Conciliacion_POS2( "' ||
                        psUsuarioParametros || '", "' || psArchivoOrigen || '", "' || psNumTarjeta || '", "' ||  vsMovCodigoISO || '", "' ||  psNomComercio || '", "' ||   psRFC  || '", "' ||
                        psSecuenciaAuth || '", ' || pmMonto || ', ' || pmMontoCashBack || ', "' ||  psMoneda || '", "' ||  vsCodTran || '", "' || psRefTransaccion || '", ' ||
                        viExisteEnMovimiento || ', "' ||  vsMovSecuencia || '", "' || vsMovSecuenciaExtendida || '", "'  || vsMovMovConciliado || '", "' ||  vsMovMoneda  || '", ' ||  vmMovMonto  || ', ' ||
                        vmMovMontoCashBack  || ', ' || vmMovMontoComision  || ', ' ||  vmMovMontoRealRevFzda || ', "' ||
                        vsMovCodTran || '", "' ||  vsmovFormato || '", "' || vsMovSecuenciaCashBack || '", ' || vmMovMontoComCashBack  || ', "' ||  vsMovSecuenciaComCashBack || '", "' ||
                        vsMovCodigoCentral || '", ' ||
                        viExisteReverzaForzada || ', "' || vsRFCodigoCentral || '", "' ||  vsRFSecuencia || '", "' || vsRFCodigoISO || '", "' ||  vsRFFormato || '", "' ||
                        vsRFCodTran || '", ' ||  vmRFMonto  || ', ' ||  vmRFMontoCashBack  || ', "' ||
                        psTipoTransaccion  || '","' || vsMovFechaLocalTransaccion || '", "' || vsMovHoraLocalTransaccion || ', "' || 
						vsTransaccionOrigen || '" ) ' ;

                        EXECUTE  PROCEDURE intercard:sp_Tipo_Conciliacion_POS2(
                        psUsuarioParametros, psArchivoOrigen, psNumTarjeta, vsMovCodigoISO, psNomComercio,  psRFC,
                        psSecuenciaAuth, pmMonto, pmMontoCashBack, psMoneda, vsCodTran, psRefTransaccion,
                        psDivisa, pmMontoDivisa, psFormadePago,
                        viExisteEnMovimiento, vsMovSecuencia, vsMovSecuenciaExtendida, vsMovMovConciliado, vsMovMoneda, vmMovMonto,
                        vmMovMontoCashBack, vmMovMontoComision, vmMovMontoRealRevFzda,
                        vsMovCodTran, vsmovFormato, vsMovSecuenciaCashBack, vmMovMontoComCashBack, vsMovSecuenciaComCashBack,
                        vsMovCodigoCentral,
                        viExisteReverzaForzada,  vsRFCodigoCentral, vsRFSecuencia, vsRFCodigoISO, vsRFFormato,
                        vsRFCodTran, vmRFMonto, vmRFMontoCashBack,
                        psTipoTransaccion, vsConvenioInterEmpresa, vsTipoTransInterEmpresa, vmMontoComInterEmpresa, vsMovFechaLocalTransaccion, vsMovHoraLocalTransaccion , vsTransaccionOrigen) 
                        INTO vsClaveAutorizacionDeTransaccion, vsMovSecComision, 
                        viStatusConciliacion, vsDESCRIPCION1,vsDESCRIPCION2, vsDESCRIPCION3, vsREGISTROCENTRAL1, vsREGISTROCENTRAL2, 
                        pmMontoReversa, viTipodeTransaccion, vsSecEnviadaCentral, vsMovSecuenciaCashBack, vsMovSecuenciaComCashBack, 
                        vsTipoEnviadaCentral, vsTipoConciliacion ;

                END IF ;

                IF ( vsTipoEnviadaCentral = 'A' ) THEN -- ES UN ABONO AL CLIENTE
                    LET vsCodTran = '21' ;
                    --LET vsRegistrado = 'F' ;
                END IF ;

        END IF ; -- IF ( vsNumCuenta = '' )

        IF ( viStatusConciliacion <> 0) THEN
         -- ESCRIBE EN LA TABLA DE MOVCONCILIADOS

	 IF ((psTipoTransaccion IN ('20', '21')) AND (psArchivoOrigen IN ('VNC', 'VND', 'VIC', 'VID'))) THEN --FILTRA LAS TRANSACCIONES DE DEVOLUCIONES Y DE LOS ARCHIVOS DE COMPRAS PARA EL REGISTRO EN LA TABLA DE REGISTRO
	     SET LOCK MODE TO WAIT 3;
	     SET ISOLATION TO DIRTY READ;
	     --OBTIENE EL NOMBRE DEL ARCHIVO EN PROCESO
	     SELECT FIRST 1 Valor INTO vsNomArchivo FROM Intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'NOMBRE_ARCHIVO';
	 
	     --REGISTRA LA DEVOLUCION EN LA TABLA DE CONTROL/DETALLE
	     EXECUTE PROCEDURE Intercard:Sp_Clasifica_Devoluciones_POS (vsNomArchivo, psArchivoOrigen, psNumTarjeta, psSecuenciaAuth, pmMonto, psNomComercio, vsRegistrado, vmMovMonto, viStatusConciliacion, vsMovMovConciliado, vdtMovFechaHoraInAuthorizer) ;
	 END IF;

            LET vsmensajeError = 'sp_InsertaMovConciliados ' ;

            LET vsCodRespBASE24 = LPAD ( TRIM ( vsMovCodigoISO ), 3, '0' ) ;

            EXECUTE PROCEDURE intercard:sp_InsertaMovConciliados (
                vsClaveAutorizacionDeTransaccion ,
                vsMovCodigoISO ,
                vsCodRespBASE24 ,
                vsCodRet  ,
                vsCodRetSurcharge ,
                vsMovCodReversa ,
                vsCodTran ,
                vsEsConvenio ,
                vsEspropio ,
                psFechaAplib ,
                SUBSTRING (REPLACE ( REPLACE ( REPLACE (CURRENT, '-', ''  ), ':', '' ), ' ', '' ) FROM 1 FOR 14 ),  --fechadeconciliacion  '20071205133103',
                psFechaReporteBreve,
                SUBSTRING (psFecha FROM 3 FOR 2 ) || '/' || SUBSTRING (psFecha FROM 5 FOR 2 ) || '/' || SUBSTRING (psFecha FROM 1 FOR 2 ),
                vdtMovFechaHoraInAuthorizer,
                SUBSTRING ( vsMovFechaLocalTransaccion FROM 3 FOR 2) || SUBSTRING ( vsMovFechaLocalTransaccion FROM 1 FOR 2) ,
                vsFormato ,
                psFuenteId ,
                vsHora,
                vsMovHoraLocalTransaccion,
                psIdComercio,
                vsMovIdReceptor,
                vmMovMontoCashBack ,
                vmMovMontoComCashBack ,
                vmMovMontoComision ,
                pmMonto,
                vmMovMontoRealRevFzda ,
                vmMovMonto,
                vmMovMontoSurcharge ,
                vsMovMovReversado ,
                vsNacional ,
                psNomComercio  ,
                vsNumCuenta ,
                psNumTarjeta ,
                vsProdInd ,
                vsReferencia ,
                psRefTransaccion,
                vsRegistrado ,
                psRFC  ,
                vsSecEnviadaCentral ,
                vsMovSecSurcharge ,
                vsMovSecuenciaCashBack ,
                vsMovSecuenciaComCashBack  ,
                vsMovSecComision ,
                viStatusConSurcharge  ,
                vsMovCodigoCentral,
                vsStatusComision ,
                viStatusConciliacion ,
                vsStatusTarjeta,
                vsTipoEnviadaCentral ,
                psArchivoOrigen ,
                vsTipoRecibidaCentral ,
                vsTnrCobroComisionCtaIndividual,
                vmTnrMontoComisionCtaIndividual
                )
                INTO vsQUERY3 ;

        END IF ;


        --IF ( ( viExisteEnMovimiento > 0 ) AND ( viStatusConciliacion <> 0) AND ( vsMovMovConciliado <> 'V' ) AND ( psTipoTransaccion <> '21' ) ) THEN
        IF ( ( viExisteEnMovimiento > 0 ) AND ( viStatusConciliacion <> 0) AND ( vsMovMovConciliado <> 'V' )) THEN

            --actualizar el movimiento en la tabla como conciliado, ya que las devoluciones no se reciben en línea, por lo tanto, el movimiento que se
            --'Localizó es en realidad la compra correspondiente a la devolución.
            LET vsmensajeError = 'sp_ActualizaMovimiento ( "' || psSecuenciaAuth || '", "' || psNumTarjeta || '", "02", "' || vdtMovFechaHoraInAuthorizer || '" )' ;
            EXECUTE PROCEDURE intercard:sp_ActualizaMovimiento ( psSecuenciaAuth, psNumTarjeta, '02', vdtMovFechaHoraInAuthorizer ) INTO vsmensajeError ;

            IF ( viExisteReverzaForzada > 0 ) THEN  --SI EXISTE UN MOVIMIENTO ORIGINAL. IDENTIFICA SI EL MOVIMIENTO ES UNA REVERSA O FORZADA
                        LET vsmensajeError = 'sp_ActualizaMovimiento ( "' || vsRFSecuencia || '", "' || psNumTarjeta || '", "02", "' || vdtMovFechaHoraInAuthorizer || '" )' ;
                        EXECUTE PROCEDURE intercard:sp_ActualizaMovimiento ( vsRFSecuencia, psNumTarjeta, '02', vdtMovFechaHoraInAuthorizer ) INTO vsmensajeError ;
            END IF ;

        END IF ;

        LET vsmensajeError = 'Guarda el recorrido de la transaccion en LOG_POS -- sp_Insertar_LOG_POS ( ) ' ;
        --GUARDA EL REGISTRO DEL LOG DE LA TRANSACCION ACTUAL

        EXECUTE PROCEDURE intercard:sp_Insertar_LOG_POS ( psArchivoOrigen, psNumTarjeta, psTipoTransaccion, pmMonto,
        pmMontoCashBack, psIdComercio, psNomComercio, psSecuenciaAuth, psRefTransaccion, psRFC,
        psFuenteId, vsNumCuenta, vsQUERY1, vsMovCodigoISO, vsFormato, vsMovMovConciliado, vsMovFechaMov, vsMovHoraMov,
        vsMovCodigoCentral, vsMovSecuenciaOrig, vsMovHoraLocalTransaccion, vmMovMontoRealRevFzda, vsCodTran,
        vsEnLinea, vsIdTerminal, vsProdInd, vsMovSecuenciaCashBack, vsMovSecuenciaComCashBack,
        vmMovMontoComCashBack, vsMovComisionEnLinea, vsMovPermiteComisionPendiente,
        vsMovGeneroComisionPendiente, vsMovSecComision, vmMovMontoComision, vsMovCodigoRetComision, vsIdReceptor,
        vsQUERY2, vsRFCodigoISO, vmRFMonto, vsRFSecuencia, vsRFFechaMov, vsRFEnLinea, vsRFIdTerminal,
        vsRFHoraLocalTransaccion, vsDESCRIPCION1, vsDESCRIPCION2, vsDESCRIPCION3, vsREGISTROCENTRAL1, vsREGISTROCENTRAL2,
        vsQUERY3, viStatusConciliacion, vsTipoConciliacion ) INTO viCodRet ;

    LET vsmensajeError = '' ;

    RETURN visqlerr, vsmensajeError ;

END
END PROCEDURE;