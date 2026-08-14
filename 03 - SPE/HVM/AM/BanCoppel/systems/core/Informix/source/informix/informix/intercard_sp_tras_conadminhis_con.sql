CREATE PROCEDURE "informix".sp_tras_conadminhis_con(cNumEmpl varchar(9))
RETURNING VARCHAR(6) as Cod_ret,VARCHAR(80) as Men_ret;
	DEFINE  SQL_ERR          INTEGER;
	DEFINE  ISAM_ERR         INTEGER;
	DEFINE  ERROR_INFO       VARCHAR(80);
	DEFINE  P_COD_RET        VARCHAR(6);
	DEFINE  P_COD_RET2       VARCHAR(6);
	DEFINE  P_MENSAJE        VARCHAR(80);
	DEFINE  iValor           INTEGER;
	DEFINE  dFechaFin        DATE;	
	DEFINE  iNumReg          INTEGER;
	
	
	--SET DEBUG FILE TO "/informix/HomeInformix/rrm/conadminhis.out";
	--TRACE ON;

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
	  
	  EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('48','Error en sp_tras_conadminhis_con ' || SQL_ERR || ' ' || P_MENSAJE,cNumEmpl) INTO P_COD_RET2;
	  
      RETURN P_COD_RET,P_MENSAJE;
   END EXCEPTION;

--************************************************************
-- Creado por Juan Fco Ponce Damian
-- fecha : 23/08/2012
-- Funcion: Traspaso de Informacion de conadmin a historico 
--************************************************************

   LET P_COD_RET = '00000';
   LET P_COD_RET2 = '00000';
   LET P_MENSAJE = 'PROCESO EXITOSO TRANSFERENCIA DE CONADMIN';
   LET iValor = 0;
   LET iNumReg = 0;

   
   	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	SELECT valor INTO iValor FROM bditarjeta:"informix".td_param_conciliacion_concreing WHERE codigo = '405';
	
		
	IF (iValor == 0) THEN
	   LET P_COD_RET = '00000';
	   LET P_MENSAJE = 'NO EXISTEN DIAS A SUBSTRAER.. ';	
	ELSE
		
		select fecha_hoy - ivalor units day into dfechafin from bdinteg:"informix".si_fechas;				
		
		set isolation to dirty read;
		select count(*) into iNumReg from Intercard:"informix".conadmin
		where fecharegistro <= dFechaFin;
		
		-- Se quito para ser insertado por bloques
		
		/*INSERT INTO intercard:"informix".conadmin_his(keyx, archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, tiporegistro, 
		fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion, cuentac, 
		cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario)
		SELECT keyx, archivoorigen, nomarchivo325, nomarchivocom, fecharegistro, tiporegistro, 
		fecha, prodtarjeta, tarjeta, cuenta, tipomov, tran_central, folio325, monto325, estatus, txnliberacion, cuentac, 
		cuentaa, foliosif, montosif, secintercard, montointcrd, fechahorainauth, idterminal, tipooperacion, usuario
		FROM intercard:"informix".conadmin
		WHERE fecharegistro <= dFechaFin; -- Para utilizar index 
						
		LET iNumReg =dbinfo("sqlca.sqlerrd2");*/
		
		EXECUTE PROCEDURE Intercard:"informix".sp_idconadminhis_cnc (dfechafin) into P_COD_RET, P_MENSAJE; -- Para Borrado por Bloques

		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('48','Exito en Traspaso de  Conadmin a Historico (sp_tras_conadminhis_con) ' || iNumReg  || ' ' || 'Registros Transferidos',cNumEmpl) INTO P_COD_RET;		
		EXECUTE PROCEDURE bditarjeta:"informix".sp_concreing_guardabitacora('48','Exito en Borrado de Movimientos ' || iNumReg  || ' ' || 'Registros Borrados',cNumEmpl) INTO P_COD_RET; -- Para registro en Bitacora de registros borrados 
	
	END IF;
     
	RETURN P_COD_RET,P_MENSAJE;
  
END;
END PROCEDURE
DOCUMENT
'Modifico: Ricardo Reséndiz Martínez',
'Proyecto: Reingenieria Conciliacion',
'Solicito: Luis Antonio Gomez',
'Descripcion: Se agrego llamado a SP para el traslado de registros y borrado de registros por bloques',
'Fecha: 2012/11/26',
'Version: 20121126.2000',
'BD: Intercard';

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