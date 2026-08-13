CREATE PROCEDURE "informix".sp_depura_movimientobpi()
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
	define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
	define  vcodtran VARCHAR(2);	
  ---SET DEBUG FILE TO "/informix/HomeInformix/rrm/init.out";
  ---TRACE ON;
	
BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vsecuencia='';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let     vmaxnumregistros=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let     vcodtran = '';
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	
	     select  maxnumregistros into  vmaxnumregistros
		 from    intercard:"informix".parametros;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select 	secuencia, fechalocaltransaccion, horalocaltransaccion,codtran
					into vsecuencia, vfechalocaltransaccion, vhoralocaltransaccion,vcodtran
			from intercard:"informix".movimiento where codtran in ('91','92','93')
			
		if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
		end if;
			
		--  Inserta datos en la tabla historica
		insert into intercard:"informix".movimientobpihistorico (secuencia, codigoiso, prodind, formato, codtran, fechamov, horamov, referencia, idterminal, motivo, fechalocaltransaccion, horalocaltransaccion, fechahorainauth, transaccionorigen, tokens63in, fechahoraoutauth, fechahorainauthj)
		select {+INDEX (movimiento  idx_movimientonew2a)} secuencia, codigoiso, prodind, formato, codtran, fechamov, horamov, referencia, idterminal, motivo, fechalocaltransaccion, horalocaltransaccion, fechahorainauth, transaccionorigen, tokens63in, fechahoraoutauth, fechahorainauthj
		from intercard:"informix".movimiento	  
		where fechalocaltransaccion = vfechalocaltransaccion AND 
		      horalocaltransaccion = vhoralocaltransaccion AND 
		      secuencia = vsecuencia AND  codtran= vcodtran;
		      --codtran in ('91','92','93');
			
			--  Borra registro de la Tabla de Movimientos
			delete {+INDEX (movimiento  idx_movimientonew2a)}  from intercard:"informix".movimiento 
		    where  fechalocaltransaccion = vfechalocaltransaccion AND 
		           horalocaltransaccion = vhoralocaltransaccion AND 
				   secuencia = vsecuencia AND codtran= vcodtran;
				   --codtran in ('91','92','93');
				
			let vicontadorregistros = vicontadorregistros + 1;

			if (vicontadorregistros = vmaxnumregistros) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
		end foreach;
		
		if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table intercard:"informix".movimientobpihistorico;      
				let vsflagentransaccion = 'F';
		end if;
		
	RETURN 	P_COD_RET,P_MENSAJE;

END;

END PROCEDURE;