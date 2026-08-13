CREATE PROCEDURE "informix".sp_movimientobpihistorico()
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	--  Variables de Errores y datos de SP
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	
	
   	--  Variables para control de contadores
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	--  Variables para datos de primary key
	define  vmaxnumregistros integer;
	define  vsecuencia  varchar (7);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		
  --SET DEBUG FILE TO "/informix/HomeInformix/rrm/init.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let     vsecuencia='';
	let     vfechalocaltransaccion='';
	let     vhoralocaltransaccion='';
	let    vmaxnumregistros=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';

	
	    select 	maxnumregistros into  vmaxnumregistros
			from intercardbpi:"informix".parametros;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select 	secuencia, fechalocaltransaccion, horalocaltransaccion
					into vsecuencia, vfechalocaltransaccion, vhoralocaltransaccion
			from intercardbpi:"informix".movimientobpi
			
		if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
		end if;
			
		--  Inserta datos en la tabla historica
		insert into intercardbpi:"informix".movimientobpihistorico (secuencia, codigoiso, prodind, formato, codtran, fechamov, horamov, referencia, idterminal, motivo, fechalocaltransaccion, horalocaltransaccion, fechahorainauth, transaccionorigen, tokens63in, fechahoraoutauth, fechahorainauthj)
		select {+INDEX (movimientobpi  idx_movimientobpinew1)} secuencia, codigoiso, prodind, formato, codtran, fechamov, horamov, referencia, idterminal, motivo, fechalocaltransaccion, horalocaltransaccion, fechahorainauth, transaccionorigen, tokens63in, fechahoraoutauth, fechahorainauthj
		from intercardbpi:"informix".movimientobpi	  
		where  secuencia = vsecuencia AND 
		fechalocaltransaccion = vfechalocaltransaccion AND 
		horalocaltransaccion = vhoralocaltransaccion;
			
			--  Borra registro de la Tabla de Movimientos	
			delete {+INDEX (movimientobpi  idx_movimientobpinew1)} from intercardbpi:"informix".movimientobpi 
		    where  secuencia = vsecuencia AND
		    fechalocaltransaccion = vfechalocaltransaccion AND 
		    horalocaltransaccion = vhoralocaltransaccion;
				
			let vicontadorregistros = vicontadorregistros + 1;
--			let vicontadorregistros2 = vicontadorregistros2 + 1;

--			if (vicontadorregistros2 = 100000) then 
--				update statistics medium for table intercardbpi:"informix".movimientobpi;           
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
				update statistics medium for table intercardbpi:"informix".movimientobpi;      
				let vsflagentransaccion = 'F';
		end if;
		
	--END IF;
	
	RETURN 	P_COD_RET,P_MENSAJE;

	--END IF;

END;

END PROCEDURE;