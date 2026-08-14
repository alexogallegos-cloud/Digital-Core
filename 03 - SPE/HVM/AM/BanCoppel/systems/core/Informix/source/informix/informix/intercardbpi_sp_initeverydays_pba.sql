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