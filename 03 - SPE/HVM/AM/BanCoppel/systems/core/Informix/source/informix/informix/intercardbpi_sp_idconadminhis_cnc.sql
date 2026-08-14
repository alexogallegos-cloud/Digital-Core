CREATE PROCEDURE "informix".sp_idconadminhis_cnc(dfechafin date)
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;

	-- Variables de Ambiente y entrada 
	define  sql_err          integer;
	define  isam_err         integer;
	define  error_info       varchar(80);
	define  p_cod_ret        varchar(6);
	define  p_mensaje        varchar(80);
	define  vdfechafin       date;	
	
   	
	--  Variables para los contadores 
	
	define  vsflagentransaccion 	char(1);
	define 	vicontadorregistros 	integer;
	define  vicontadorregistros2 	integer;
    
	-- 	Variables de primary key
	
	define 	vfecharegistro		date;
	define	vkeyx				integer;
	define	vnomarchivo325		char (20);
	define	vnomarchivocom		char (21);
	
	
	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/deltdconadminhis.out";
	--TRACE ON;

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

	let 	vfecharegistro		= today;
	let		vkeyx				= 0;
	let		vnomarchivo325		= '';
	let		vnomarchivocom		= '';
	

	let p_cod_ret = '00000';
	let p_mensaje = 'Proceso Exitoso';
   
	set isolation to dirty read;
    foreach cusor1 with hold
          for    
			select fecharegistro,keyx,nomarchivo325,nomarchivocom 
				into vfecharegistro,vkeyx,vnomarchivo325,vnomarchivocom 
				from Intercard:"informix".conadmin
				where fecharegistro <= dFechaFin
					
			if(vsflagentransaccion = 'F') then
              begin work;
                let vsflagentransaccion = 'V';
            end if;
			
			-- Inserta en tabla de Historicos 
			insert into intercard:"informix".conadmin_his
				(keyx, archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, tiporegistro, 
				fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion, cuentac, 
				cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario)
			select 
				keyx, archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, tiporegistro, 
				fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion, cuentac, 
				cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario
			from intercard:"informix".conadmin
			where 	fecharegistro = vfecharegistro 	and
					keyx = vkeyx					and
					nomarchivo325 = vnomarchivo325 	and
					nomarchivocom = vnomarchivocom;

			
			--  Borra de Tabla de Movimientos	
			delete from Intercard:"informix".conadmin
			where 	fecharegistro = vfecharegistro 	and
					keyx = vkeyx					and
					nomarchivo325 = vnomarchivo325 	and
					nomarchivocom = vnomarchivocom;
			
			--  Borra la tabla de Secuencias 
			
			let vicontadorregistros = vicontadorregistros + 1;
			let vicontadorregistros2 = vicontadorregistros2 + 1;

			if (vicontadorregistros2 = 5000) then 
				update statistics medium for table Intercard:"informix".conadmin;           
				let vicontadorregistros2 = 0;
			end if;

			if (vicontadorregistros = 1000) then
				commit work;
				let vsflagentransaccion = 'F';
				let vicontadorregistros = 0;
				continue foreach;
			end if;		
	end foreach;
		
	if ((vicontadorregistros > 0) or (vsflagentransaccion = 'V')) then
        commit work;
        update statistics medium for table Intercard:"informix".conadmin;    
        let vsflagentransaccion = 'F';
    end if;
		
    
	RETURN 	P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE;