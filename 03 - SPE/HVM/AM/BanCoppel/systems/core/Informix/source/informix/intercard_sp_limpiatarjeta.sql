CREATE PROCEDURE "informix".sp_limpiatarjeta( pcNumTarjeta CHAR(16),pcNumCredito CHAR(16))
RETURNING CHAR(5) AS CodigoRetorno;

-- *	DEFINICION DE VARIABLES
	DEFINE cCodRet 		CHAR(3);
	DEFINE iSqlErr 		INTEGER;
	DEFINE iCont		INTEGER;
	DEFINE dFhora       DATE;
	DEFINE dFinsert     DATE;
	DEFINE cDif        INTEGER;
	

-- *	ASIGNACION DE VARIABLES
	LET cCodRet 		= '000';
	LET iSqlErr 		= 0;
	LET iCont			= 0;
	LET dFhora          = '';
	LET dFinsert        = '';
	LET cDif            = 0;

-- *	CONTROL DE ERRORES
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/Guicho/sp_limpiatarjeta.out"; -DSB20180619
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PAR?METROS VACIOS O NULOS
	IF NVL(TRIM(pcNumTarjeta),'') = '' THEN
		LET cCodRet = '101';
		RETURN cCodRet;
	ELIF NVL(TRIM(pcNumCredito),'') = '' THEN
		LET cCodRet = '100';
		RETURN cCodRet;
	END IF;

	--Se agrega validación para solo eliminar de las bases de datos bdicred en caso de que la tarjeta no este asignada en intercard
	select count(fechaasignacion) into iCont
	FROM intercard:"informix".tarjeta
	WHERE numtarjeta = pcNumTarjeta AND fechaasignacion IS NOT NULL;
	
		IF iCont < 1 THEN
		--IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjeta AND num_credito = pcNumCredito) THEN -DSB20180619

			--------- Elimina los registros en la tabla sd_tarjeta
			DELETE FROM bdicred:"informix".sd_tarjeta
			WHERE empresa = '001' AND num_tarjeta = pcNumTarjeta;

            --OFI20230601 inicio
            DELETE FROM intercard:"informix".tarjeta_indicadores
             WHERE empresa = '001'
               AND numtarjeta = pcNumTarjeta;
            --OFI20230601 fin


		
			/* Se comenta borrado de credito ya que las asignacion de TDC no debe borrar un credito ya aperturado, aun si la asignacion fue incorrecta. / Feb 2022
	
			----- Regresar la solictud AT
			UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT"
			WHERE empresa= '001'
            AND num_solicitud = pcNumCredito;

			DELETE FROM bdicred:"informix".SD_MAESDOS
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;

			DELETE FROM bdicred:"informix".SD_MOVDIA
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;

			DELETE FROM bdicred:"informix".SD_MAECREDANEXO
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;

			DELETE FROM bdisolic:"informix".ss_autorizacion
			WHERE empresa= '001'
            AND num_solicitud = pcNumCredito
			AND status_solicitud = "AP";

			DELETE FROM bdicred:"informix".sd_amortiza_credito
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;

			DELETE FROM bdicred:"informix".SD_MAECRED
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;

			DELETE FROM bdicred:"informix".SD_INDICADOR_CRED
			WHERE EMPRESA= '001'
			AND NUM_CREDITO = pcNumCredito;
			*/
			------------------------

		--END IF;	-DSB20180619
		-- Se trae la fecha actual para validar entre la apertura
		
		Select fecha_insert, DATE(FECHA_HORA), 
        cast( substr( TRIM(CAST(extend(sysdate,hour to second) - extend(fecha_hora,hour to second) AS CHAR(25))), 1,1)as int)
        INTO dFinsert, dFhora, cDif
        From bdisolic:ss_autorizacion where num_solicitud = pcNumCredito and status_solicitud = 'AP';
		  
		  IF dFhora = dFinsert THEN
		    IF cDif < 1 THEN
			     UPDATE bdisolic:"informix".ss_solicitudes SET status_solicitud = "AT"
			     WHERE empresa= '001'
                 AND num_solicitud = pcNumCredito;

			     DELETE FROM bdicred:"informix".SD_MAESDOS
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;

			     DELETE FROM bdicred:"informix".SD_MOVDIA
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;

			     DELETE FROM bdicred:"informix".SD_MAECREDANEXO
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;

			     DELETE FROM bdisolic:"informix".ss_autorizacion
			     WHERE empresa= '001'
                 AND num_solicitud = pcNumCredito
			     AND status_solicitud = "AP";

			     DELETE FROM bdicred:"informix".sd_amortiza_credito
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;

			     DELETE FROM bdicred:"informix".SD_MAECRED
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;

			     DELETE FROM bdicred:"informix".SD_INDICADOR_CRED
			     WHERE EMPRESA= '001'
			     AND NUM_CREDITO = pcNumCredito;
			 END IF;
        END IF;			 

		
END IF;

	RETURN cCodRet;
END;
END PROCEDURE
DOCUMENT
'Folio.........: 1417-MTTO-APERTC',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 22/04/2014',
'Modificación..: Se crea procedimiento para validar si hay registros de la tarjeta en la tabla "sd_tarjeta" y eliminarlos.',
'Sustento......: INC 24 113 Suc_Asignacion_incompleta_de_TDC_0001_v1.1',
'Solicita......: Cutberto Gonzalez',
'BD............: INTERCARD',
'*************************************************************************************************************************',
'Folio.........: 1873-INC_TDC_INCOMPLETAS',
'Autor.........: 95519203 - Jesus Ivan Garcia Guicho',
'Fecha.........: 19/06/2018',
'Modificación..: Se modifica sp se comenta validacion si existe en  bdicred:"informix".sd_tarjeta ya que otro sp sp_validaAsignaTarjetaIncompleta de la BD:bdicred',
'                valida si no existe la tarjeta asignada a ese cliente en la tabla bdicred:"informix".sd_tarjeta',
'Sustento......: Correo Tarjetas TDC Incompletas',
'Etiqueta......: -DSB20180619',
'Solicita......: Cutberto Gonzalez',
'BD............: INTERCARD',
'**************************************************************************************************************************',
'Folio.........: RQI 23 1486 - Reposición de tdc oro limpiar tarjeta_indicadores',
'Autor.........: 90258203 - Héctor Vargas Olivares',
'Fecha.........: 01/06/2023',
'Modificación..: Se agrega delete de la tabla tarjeta_indicadores',
'Sustento......: ID 347158 Corima',
'Etiqueta......: OFI20230601',
'Solicita......: Fermín Ramos García',
'BD............: INTERCARD';

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