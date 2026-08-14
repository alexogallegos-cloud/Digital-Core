CREATE PROCEDURE "informix".sp_tarbanda_pba()
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
    define 	vicontadorregistros3 	integer;
	define  vicontadorregistros4 	integer;
	define  vconsecutivo            integer;
    
	--  Variables para datos de primary key
	
	define  vfechaexp		CHAR(4);
	define 	vmaxfechaexp  	CHAR(4);
    define 	vminfechaexp   	CHAR(4);
	---SET DEBUG FILE TO "/informix/resplogifx/tarbanda.out";
	---TRACE ON;

BEGIN
	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
	LET P_COD_RET    = SQL_ERR;
	LET P_MENSAJE  = ERROR_INFO;
	
    RETURN 	P_COD_RET,P_MENSAJE;
		
   END EXCEPTION;

--************************************************************
-- Creado por Ricardo Reséndiz Martinez 
-- fecha : Nov/2012
-- Funcion: Borrado de registros de tablas productivas   
--************************************************************
	
	
	let 	vsflagentransaccion = 'F';
	let		vicontadorregistros = 0;
	let     vicontadorregistros2 = 0;
	let		vicontadorregistros3 = 0;
	let     vicontadorregistros4 = 0;
	let     vconsecutivo = 0;
	
	
	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';
	
	
	set isolation to dirty read;
	SELECT max(fechaexp) into vmaxfechaexp FROM intercard:td_bandacontrol;
	SELECT min(fechaexp) into vminfechaexp FROM intercard:fechaexp;
	
	
		   IF 	vmaxfechaexp IS NULL  OR vmaxfechaexp = '' THEN
		   
		       set isolation to dirty read;
		    foreach cusor1 with hold
				for    
			 select fechaexp
					into vfechaexp
			        from intercard:fechaexp
			
		    if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			
			--  Inserta datos en la tabla historica
			insert into td_bandacontrol(numtarjeta,cuenta,numcliente,codstatustarjeta,codproductotarjeta,fechaexp)
			SELECT {+INDEX(intercard:tarjeta 144_89)} {+INDEX(intercard:tarjeta idx_numcte)} {+INDEX(intercard:tarjetacuenta  128_56)} {+INDEX(bdicheq:sc_sdodiarioc cuenta)} 
		    tar.numtarjeta,sc.cuenta,tar.numcliente,tar.codstatustarjeta,tar.codproductotarjeta,tar.fechaexp	
			FROM intercard:tarjeta tar,intercard:tarjetacuenta tc,bdicheq:sc_tarjeta sc,intercard:lote lte,bdicheq:sc_producto proc,bdinteg:si_cliente si
			WHERE tar.numtarjeta = tc.numtarjeta
			AND tc.numtarjeta = sc.num_tarjeta
			AND sc.num_tarjeta = tar.numtarjeta
			AND tc.numcuenta = sc.cuenta
			AND tar.numcliente = sc.numcte
			AND sc.numcte = si.numcte
			AND si.numcte = tar.numcliente
			AND sc.prodtarjeta = proc.producto
			AND tar.numerolote = lte.numerolote
            AND fechaexp = vfechaexp
			AND lte.clave_tipotarjeta in (3,4)
			AND tar.codstatustarjeta in ('ACT','BLO','BLT')
			AND proc.producto in ('2000','1900','1500','2500','1300','1400','1700','1800')
            AND sc.secuencia = '1'
			AND sc.status_tar ='A';
			
			--  Borra registro de la Tabla de Movimientos	
			delete from intercard:"informix".fechaexp 
			where 	fechaexp = vfechaexp;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 300000) then 
				update statistics medium for table intercard:td_bandacontrol;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 5000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
	    end foreach;
		
		    if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table intercard:td_bandacontrol;      
				let vsflagentransaccion = 'F';
		    end if;
	ELSE
	            let vmaxfechaexp = '';
				let vminfechaexp = '';
				
			set isolation to dirty read;
	           SELECT max(fechaexp) into vmaxfechaexp FROM intercard:td_bandacontrol;
	           SELECT min(fechaexp) into vminfechaexp FROM intercard:fechaexp;
	
			   IF 	vmaxfechaexp = vminfechaexp THEN

					foreach cusor2 with hold
					  for  
					  
					  SELECT consecutivo  into vconsecutivo FROM intercard:td_bandacontrol
					  
					  
						    if(vsflagentransaccion = 'F') then
				              begin work;
                              let vsflagentransaccion = 'V';
                            end if;
					  
					    DELETE from  intercard:td_bandacontrol  
						WHERE consecutivo = vconsecutivo
						AND fechaexp = vmaxfechaexp;
						
				   
					   let vicontadorregistros3 = vicontadorregistros3 + 1;
					   let vicontadorregistros4 = vicontadorregistros4 + 1;

					   if (vicontadorregistros3 = 100000) then 
						  update statistics medium for table intercard:td_bandacontrol;           
						  let vicontadorregistros3 = 0;
						end if;

						if  (vicontadorregistros4 = 5000) then
						  commit work;
						  let vicontadorregistros4 = 0;
						  let vsflagentransaccion = 'F';
						   continue foreach;
						end if;		
					end foreach;
					
    set isolation to dirty read;
		foreach cusor3 with hold
				for    
			 select 	fechaexp
					into vfechaexp
			        from intercard:fechaexp
			
		    if(vsflagentransaccion = 'F') then
				begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			
			--  Inserta datos en la tabla historica
			insert into td_bandacontrol(numtarjeta,cuenta,numcliente,codstatustarjeta,codproductotarjeta,fechaexp)
			SELECT {+INDEX(intercard:tarjeta 144_89)} {+INDEX(intercard:tarjeta idx_numcte)} {+INDEX(intercard:tarjetacuenta  128_56)} {+INDEX(bdicheq:sc_sdodiarioc cuenta)} 
		    tar.numtarjeta,sc.cuenta,tar.numcliente,tar.codstatustarjeta,tar.codproductotarjeta,tar.fechaexp	
			FROM intercard:tarjeta tar,intercard:tarjetacuenta tc,bdicheq:sc_tarjeta sc,intercard:lote lte,bdicheq:sc_producto proc,bdinteg:si_cliente si
			WHERE tar.numtarjeta = tc.numtarjeta
			AND tc.numtarjeta = sc.num_tarjeta
			AND sc.num_tarjeta = tar.numtarjeta
			AND tc.numcuenta = sc.cuenta
			AND tar.numcliente = sc.numcte
			AND sc.numcte = si.numcte
			AND si.numcte = tar.numcliente
			AND sc.prodtarjeta = proc.producto
			AND tar.numerolote = lte.numerolote
            AND fechaexp = vfechaexp
			AND lte.clave_tipotarjeta in (3,4)
			AND tar.codstatustarjeta in ('ACT','BLO','BLT')
			AND proc.producto in ('2000','1900','1500','2500','1300','1400','1700','1800')
            AND sc.secuencia = '1'
			AND sc.status_tar ='A';
			
			--  Borra registro de la Tabla de Movimientos	
			delete from intercard:"informix".fechaexp 
			where 	fechaexp = vfechaexp;
				
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 300000) then 
				update statistics medium for table intercard:td_bandacontrol;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 5000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
	    end foreach;
		
		    if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
				commit work;
				update statistics medium for table intercard:td_bandacontrol;      
				let vsflagentransaccion = 'F';
		    end if;
		
	END IF;
END IF;
	
	RETURN 	P_COD_RET,P_MENSAJE;



END;
END PROCEDURE;