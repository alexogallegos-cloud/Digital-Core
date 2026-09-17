CREATE PROCEDURE "informix".sp_arqcvalidoshistorico()
RETURNING VARCHAR(6) as Cod_ret, VARCHAR(80) as Men_ret;

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
	define  vperiododepuracion integer;
	define  vsecuencia  varchar (7);
	define  vsecuenciaextendida  varchar (16);
	define  vfechalocaltransaccion  varchar (4);
	define  vhoralocaltransaccion  varchar (6);
		


BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

	let		vsecuenciaextendida='';
	let		vperiododepuracion=0;
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let		vicontadorregistros2 = 0;
	let		p_cod_ret = '00000';
	let		p_mensaje = 'Proceso Exitoso.';
	let            vmaxnumregistros = 0;
	--set debug file to '/tmp/sp_arqcvalidoshistorico.out';
	--trace on;
		select 	maxnumregistros into  vmaxnumregistros
			from intercard:"informix".parametros;
		select periododepuracion into vperiododepuracion
			from intercard:"informix".parametros;
					
	set isolation to dirty read;
		foreach cusor1 with hold
				for    
				select {+INDEX (movimiento  idx_fechahorainauth)} m.secuenciaextendida
					into vsecuenciaextendida
				from intercard:"informix".movimiento m 
					inner join intercard:"informix".arqcvalidos a on 
						m.metodocaptura = '05' 
						and fechahorainauth < (CURRENT - (vperiododepuracion units day))  
						and m.secuenciaextendida = a.secuenciaextendida
			
                if(vsflagentransaccion = 'F') then
			begin work;
	                let vsflagentransaccion = 'V';
		end if;
			
		--  Inserta datos en la tabla historica
		
		
		insert into arqcvalidoshistorico 
		select secuenciaextendida, arqccalculado 
		from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
		
		--  Borra registro de la Tabla de arqcvalidos	
		delete from intercard:"informix".arqcvalidos 
		where secuenciaextendida = vsecuenciaextendida;
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
				let vsflagentransaccion = 'F';
		end if;

	RETURN 	P_COD_RET,P_MENSAJE;
END;

END PROCEDURE;