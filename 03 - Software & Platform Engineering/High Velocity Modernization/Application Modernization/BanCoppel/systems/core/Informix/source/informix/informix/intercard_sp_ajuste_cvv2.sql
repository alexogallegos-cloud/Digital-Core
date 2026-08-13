CREATE PROCEDURE "informix".sp_ajuste_cvv2
(
	inTipoAjuste 			CHAR(1),
	inNombreArchivoCarga	CHAR(100),
	inRutaArchivoCarga		CHAR(100),
	inFechaExpiracion		CHAR(4)
)
RETURNING 
	CHAR(5) AS codigo, 
	CHAR(100) AS descripcion;

	-- Variables para el control de errores, codigos y mensajes
	DEFINE vCodigoRetorno		CHAR(5);
	DEFINE vMensaje 			CHAR(160);
	DEFINE SQLERR 				INTEGER;
    DEFINE ISAM_ERR 			INTEGER;
   	DEFINE ERROR_INFO 			VARCHAR(80);
	
	-- Variables para el control de la carga de informacion
	DEFINE vIntervaloCommit		INTEGER;
	DEFINE vExecuteSQL		    LVARCHAR(1000);
	DEFINE vNombreCompTXT		VARCHAR(100);
	DEFINE vNombreCompLog		VARCHAR(100);
	DEFINE vNombreEjecucionLog  VARCHAR(100);
	DEFINE vNombreArchivo       VARCHAR(100);
	DEFINE vNombreRuta		    VARCHAR(100);
	DEFINE vContadorRegistros	INTEGER;

	-- Variables para el manejo de CVV2
	DEFINE vNumeroTarjeta 			CHAR(16);
	DEFINE vNumeroTarjetaCVV2 		CHAR(16);
	DEFINE vNumeroCuenta 			VARCHAR(13);
	DEFINE vNumeroCliente 			VARCHAR(13);
	DEFINE vTitular 				VARCHAR(1);
	DEFINE vTabla 					VARCHAR(50);
	DEFINE vCampo 					VARCHAR(50);
	DEFINE vTransaccion 			VARCHAR(1);
	DEFINE vBanderaCVV2				CHAR(1);
	DEFINE vFechaExpiracion			CHAR(4);
	
	-- Inicializacion de variables
	LET vCodigoRetorno		= '00000';
	LET vMensaje 			= '';
	LET SQLERR 				= 0;
    LET ISAM_ERR 			= 0;
   	LET ERROR_INFO 			= '';
	
	LET vNombreArchivo          = inNombreArchivoCarga; 
	LET vNombreRuta		    	= TRIM(inRutaArchivoCarga);
	LET vIntervaloCommit		= 1000;
	LET vExecuteSQL		    	= '';
	LET vNombreCompTXT			= TRIM(vNombreRuta) || "/dbload_numeros_clientes_cvv2_ed.txt";
	LET vNombreCompLog			= TRIM(vNombreRuta) || "/dbload_numeros_clientes_cvv2_ed.log";
	LET vNombreEjecucionLog  	= TRIM(vNombreRuta) || "/dbload_numeros_clientes_cvv2_ed_rep.log";
	LET vContadorRegistros	    = 0;
	
	LET vNumeroTarjeta 			= '';
	LET vNumeroTarjetaCVV2 		= '';
	LET vNumeroCuenta 			= '';
	LET vNumeroCliente 			= '';
	LET vTitular 				= '';
	LET vTabla 					= 'intercard.tarjeta_indicadores';
	LET vCampo 					= 'tarjeta_indicadores.cvv2dinamico';
	LET vTransaccion 			= '0'; -- Bandera apagada para que no haga Rollback en caso de falla en SELECT 
	LET vBanderaCVV2			= '';
	LET vFechaExpiracion		= inFechaExpiracion;

BEGIN
	ON EXCEPTION SET SQLERR, ISAM_ERR, ERROR_INFO
        IF SQLERR <> 0 THEN
			LET vCodigoRetorno 	= SQLERR;
			LET vMensaje  		= ERROR_INFO;
			
			-- Se valida si es necesario terminar el ultimo bloque de ejecucion
			IF (vContadorRegistros > 0) OR (vTransaccion <> '0') THEN 
				LET vCodigoRetorno 	= SQLERR;
				LET vMensaje 		= ERROR_INFO;
				COMMIT WORK;
			END IF;
				
			RETURN vCodigoRetorno, vMensaje;
        END IF;
    END EXCEPTION;
	
	-- En cado de que se tenga una transaccion abierta y tratar de abrir otra
    ON EXCEPTION IN (-535)
		-- Se termina la transaccion actual y se continua
        COMMIT WORK; 
    END EXCEPTION WITH RESUME;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	-- Se limpia la tabla de paso 
	TRUNCATE TABLE td_numeros_tarjetas_cliente_cvv2;
	
	-- Comienza Load de archivo con los clientes de CVV2
	LET vCodigoRetorno = '00001';        
	LET vMensaje = 'GENERAR COMANDO DE CARGA.';
	
	LET vExecuteSQL = '';
	LET vExecuteSQL = "echo "||'"'|| "FILE '"|| TRIM(vNombreRuta) || '/' || TRIM(vNombreArchivo)|| "' delimiter '"|| '|' ||"' "|| '3'||
					  "; INSERT INTO "|| 'td_numeros_tarjetas_cliente_cvv2' || ";"||'"'||' > '|| vNombreCompTXT;
	SYSTEM vExecuteSQL;
	
	LET vCodigoRetorno = '00002';        
	LET vMensaje = 'EJECUTAR CARGA DE ARCHIVO.';
	
	LET vExecuteSQL = '';
	LET vExecuteSQL = "dbload -d intercard -c " || vNombreCompTXT || " -l " || vNombreCompLog || " -n " || vIntervaloCommit ||" -r > "||vNombreEjecucionLog;
	SYSTEM vExecuteSQL; 
	
	LET vCodigoRetorno = '00000';        
	LET vMensaje = 'ARCHIVO CARGADO';
	
	FOREACH WITH HOLD
	
		SELECT numcliente
		INTO vNumeroCliente
		FROM td_numeros_tarjetas_cliente_cvv2
		
		IF vNumeroCliente IS NOT NULL THEN
			FOREACH WITH HOLD
				
				SELECT numtarjeta, numcliente, titular
				INTO vNumeroTarjeta, vNumeroCliente, vTitular
				FROM intercard:tarjeta
				WHERE numcliente = vNumeroCliente
				AND codstatustarjeta IN ('ACT', 'BLO', 'INA')
				AND codstatusasignada = 'SIA' 
				AND fechaexp >= vFechaExpiracion

				IF (vTransaccion = '0') THEN 
					BEGIN WORK;
					LET vTransaccion = '1';
				END IF;
									
				SELECT numtarjeta, cvv2dinamico
				INTO vNumeroTarjetaCVV2, vBanderaCVV2
				FROM intercard:tarjeta_indicadores
				WHERE numtarjeta = vNumeroTarjeta;
			
				IF vBanderaCVV2 = 'F' THEN
					IF vNumeroTarjetaCVV2 IS NOT NULL THEN
						-- Se hace el UPDATE del campo de CVV2 a verdadero, es decir, dinamico
						UPDATE intercard:tarjeta_indicadores 
						SET cvv2dinamico = 'V'
						WHERE numtarjeta = vNumeroTarjeta;
						
						INSERT INTO intercard:bitacoracambiostarjeta (secuencial, tarjeta, numcliente, titular, tabla, campo, valoranterior, valornuevo, fechacambio, usuariocambio, identificadorcambio, descripcioncambio)  
						VALUES (0, vNumeroTarjeta, vNumeroCliente, vTitular, vTabla, vCampo, vBanderaCVV2, 'V', CURRENT YEAR TO FRACTION(3), 'intercard' , '0', 'update activa cvv2 dinamico CC');
					END IF;
					
					LET vContadorRegistros = vContadorRegistros + 1;
					
					-- Se verifica si se alcanzo el maximo de transacciones por bloque
					IF (vContadorRegistros = vIntervaloCommit) THEN 
						COMMIT WORK;
						LET vTransaccion = '0';
						LET vContadorRegistros = 0;
					END IF;
				END IF;
			END FOREACH;
		END IF;
	END FOREACH;
	
	RETURN vCodigoRetorno, vMensaje;
END;
END PROCEDURE;