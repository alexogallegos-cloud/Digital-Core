CREATE PROCEDURE "informix".sp_limpiatarjeta( pcNumTarjeta CHAR(16),pcNumCredito CHAR(16))
RETURNING CHAR(5) AS CodigoRetorno;

-- *	DEFINICION DE VARIABLES
	DEFINE cCodRet 		CHAR(3);
	DEFINE iSqlErr 		INTEGER;

-- *	ASIGNACION DE VARIABLES
	LET cCodRet 		= '000';
	LET iSqlErr 		= 0;

-- *	CONTROL DE ERRORES
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/Gisela/sp_limpiatarjeta_detalle.out";
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;	
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARÁMETROS VACÍOS O NULOS
	IF NVL(TRIM(pcNumTarjeta),'') = '' THEN
		LET cCodRet = '101';
		RETURN cCodRet;
	ELIF NVL(TRIM(pcNumCredito),'') = '' THEN
		LET cCodRet = '100';
		RETURN cCodRet;
	END IF;

	--Se agrega validación para solo eliminar de las bases de datos bdicred en caso de que la tarjeta no este asignada en intercard
	IF NOT EXISTS(SELECT fechaasignacion FROM intercard:"informix".tarjeta WHERE numtarjeta = pcNumTarjeta AND fechaasignacion IS NOT NULL) THEN		
		IF EXISTS (SELECT num_tarjeta FROM bdicred:"informix".sd_tarjeta WHERE empresa = '001' AND num_tarjeta = pcNumTarjeta AND num_credito = pcNumCredito) THEN
			
			--------- Elimina los registros en la tabla sd_tarjeta
			DELETE FROM bdicred:"informix".sd_tarjeta 
			WHERE empresa = '001' AND num_tarjeta = pcNumTarjeta;
			
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
			------------------------
			
		END IF;	
	END IF;

	RETURN cCodRet;
END
END PROCEDURE
DOCUMENT
'Folio.........: 1417-MTTO-APERTC',
'Autor.........: 94565457 - Jose Angel Gaxiola Gaxiola',
'Fecha.........: 22/04/2014',
'Modificación..: Se crea procedimiento para validar si hay registros de la tarjeta en la tabla "sd_tarjeta" y eliminarlos.',
'Sustento......: INC 24 113 Suc_Asignación_incompleta_de_TDC_0001_v1.1',
'Solicita......: Cutberto Gonzalez',
'BD............: INTERCARD';

CREATE PROCEDURE "informix".sp_initeverydays_pba()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechafin       date;	
	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vconsecutivo		integer;
	define 	varchivoorigen  	CHAR(3);
    --  define 	vfechacarga      	DATETIME YEAR to FRACTION(3);
    define 	vfechacarga      	DATETIME YEAR to FRACTION(5);
    define 	vnombrearchivo   	CHAR(23);
	define  vperiododepuracion  integer;
	define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vnumtarjeta  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		
  --SET DEBUG FILE TO "/informix/HomeInformix/rrm/init.out";
  ---TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vconsecutivo = 0;
	let 	varchivoorigen = '';
    ---let 	vfechacarga = current;
    let 	vfechacarga = sysdate;
    let 	vnombrearchivo = '';
	let     vperiododepuracion =0;
	let     vsecuencia='';
	let     vnumtarjeta='';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let    vmaxnumregistros=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	
	select 	periododepuracion, maxnumregistros
					into vperiododepuracion , vmaxnumregistros
			from intercard:"informix".parametros;
			
			let  vfechacarga = vfechacarga - vperiododepuracion UNITS DAY;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select 	{+INDEX (movimiento idx_fechahorainauth)} secuencia, numtarjeta, fechalocaltransaccion, horalocaltransaccion
					into vsecuencia, vnumtarjeta, vfechalocaltransaccion, vhoralocaltransaccion
			from intercard:"informix".movimiento
		    where fechahorainauth < vfechacarga 
			
			if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
		--  Inserta datos en la tabla historica
		insert into intercard:"informix".MovimientoHistorico (secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge)
		select secuencia, codigoiso, codgironeg, codigocentral, numtarjeta, enlinea, enviado, prodind, formato, codtran, tipoctaorigen, tipoctadestino, fechaexptarj, fechamov, horamov, codreversa, moneda, referencia, monto, infreceptor, idreceptor, idterminal, montorealrevfzda, secuenciaorig, pinvalido, cvvvalido, preautorizacion, movreversado, fechaapliccentral, esnacional, pais, metodocaptura, motivo, draftcaptura, prosaauth, authhost, hostauth, authprosa, cobrocomision, montocomision, movconciliado, fechalocaltransaccion, horalocaltransaccion, fechacaptura, trancajeropropio, fechahorainauth, comisionenlinea, codigoretcomision, seccomision, tnrcobrocomisionctaindividual, tnrmontocomisionctaindividual, permitecomisionpendiente, generocomisionpendiente, movduranteactsaldos, montosurcharge, secsurcharge, montocashback, secuenciacashback, secuenciacomcashback, montocomcashback, cvv2valido, transaccionorigen, tipotransaccionposdigitada, tokens63in, trancajeroconvenio, codigoisorev, fechahoraoutauth, fechahorabcentral, fechahoraacentral, fechahorainauthj, idretailer, tipotransaccionpos, secuenciaextendida, surcharge
		from intercard:"informix".movimiento	  
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
			
			--  Borra registro de la Tabla de Movimientos	
			delete from intercard:"informix".movimiento 
		where fechahorainauth < vfechacarga AND
		secuencia = vsecuencia AND
		numtarjeta = vnumtarjeta AND
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
				
			let vicontadorregistros = vicontadorregistros + 1;
--			let vicontadorregistros2 = vicontadorregistros2 + 1;

--			if (vicontadorregistros2 = 100000) then 
--				update statistics medium for table intercard:"informix".movimiento;           
--			let vicontadorregistros2 = 0;
--			end if;

			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table intercard:"informix".movimiento;      
				let vsflagentransaccion = 'F';
		end if;
		
	--END IF;
	
	RETURN 	P_COD_RET,P_MENSAJE;

	--END IF;

END;

END PROCEDURE;