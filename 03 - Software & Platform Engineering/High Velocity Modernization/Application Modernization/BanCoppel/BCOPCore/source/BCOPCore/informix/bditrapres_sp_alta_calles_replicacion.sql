CREATE PROCEDURE "informix".sp_alta_calles_replicacion(
 _numerocalle   int, 
 _nombrecalle   char(30), 
 _fechainserta  date, 
 _usuario       char(8), 
 _fechactualiza date,
 _ApPat         char(26), 
 _ApMat         char(26), 
 _Nom1          char(26), 
 _Nom2          char(26), 
 _Ip            char(20))

   RETURNING char(10), CHAR(50);

   define vfecha_hoy date;
   define vmensaje char(50);
   define vcodigo char(10);
   define iSqlErr integer;
   define error_data_var VARCHAR(80);
	 define isam_err  integer;
	 define dFecha_hoy_1 date;
	 define dFecha_upd date;
	   
   let vmensaje = 'Registro exitoso';
	 let vcodigo = '000000';
	 let dFecha_hoy_1 = today;
	 let vfecha_hoy = date(1);
	 let dFecha_upd = _fechactualiza;

begin	 

	ON EXCEPTION SET iSqlErr,isam_err, error_data_var
	   IF iSqlErr != 0 THEN
		   let vcodigo = iSqlErr; 
		   let vmensaje = error_data_var;
		   RETURN vcodigo, vmensaje || '-' || iSqlErr;
	   END IF;
	END EXCEPTION;
	
--SET DEBUG FILE TO "/pisa/sp_alta_calles_replicacion.out";
--TRACE ON; 		

 set isolation to dirty read;
 set lock mode to wait 3;

 
	if NVL(_numerocalle,'') = ''  then
		let vcodigo = "000002";
		let vmensaje = "No se capturo numero de calle";
	elif NVL(TRIM(_nombrecalle),'') = '' then
		let vcodigo = "000003";
		let vmensaje = "No se capturo nombre de la calle";
  end if;
  
  if NVL(TRIM(_usuario),'') = '' then 
	  let vcodigo = "000004";
		let vmensaje = "No se capturo el usuario";
	elif NVL(TRIM(_Nom1),'') = ''  then 
		let vcodigo = "000006";
	  let vmensaje = "No se capturo el Nombre";	
  elif trim(_usuario) = trim(_Nom1) then
     if NVL(TRIM(_Ip),'') = ''  OR  NOT EXISTS (SELECT ip FROM bdicobranza:cb_ips_predictivo WHERE ip = TRIM(_Ip)) then 
		    let vcodigo = "000007";
	      let vmensaje = "No se capturo la IP o IP incorrecta";
	   elif NVL(_fechainserta,'') = '' then
		    let vcodigo = "000008";
	      let vmensaje = "No se capturo la fecha de insercion";  
	   end if
	else   
    if NVL(TRIM(_ApPat),'') = '' then 
  		let vcodigo = "000005";
  	  let vmensaje = "No se capturo el Apellido Paterno";
  	elif NVL(TRIM(_Ip),'') = ''  OR  NOT EXISTS (SELECT ip FROM bdicobranza:cb_ips_predictivo WHERE ip = TRIM(_Ip)) then 
  		let vcodigo = "000007";
  	  let vmensaje = "No se capturo la IP o IP incorrecta";
  	elif NVL(_fechainserta,'') = '' or NVL(_fechainserta,'') = '01/01/1900' then
  		let vcodigo = "000008";
  	  let vmensaje = "No se capturo la fecha de insercion";  
  	end if 
	end if;
	
	if NVL(_fechainserta,'') = '01/01/1900' or NVL(_fechainserta,'') > dFecha_hoy_1 then
	   ---let _fechainserta = dFecha_hoy_1;
	   let vfecha_hoy = dFecha_hoy_1;
	else 
	   let vfecha_hoy = _fechainserta;
  end if; 
	
			
if TRIM(vcodigo)<>'000000' then
			--Párametros de entrada vacíos
			-- Se Guarda en Bitacora
			INSERT INTO bdicobranza:cb_bitacora_predictivo(transaccion, ip, fecha, hora, ejecutivo, apellido_pat, apellido_mat, pri_nombre, seg_nombre, codigo_retorno)
			 VALUES('RPCALLE', NVL(TRIM(_Ip),''), TODAY, CURRENT HOUR TO SECOND, NVL(TRIM(_usuario),''), NVL(TRIM(_ApPat),''),
					     NVL(TRIM(_ApMat),''), NVL(TRIM(_Nom1),''), NVL(TRIM(_Nom2),''),vcodigo);
else
	
	if exists(select numerocalle from bdinteg:si_catcalles where numerocalle = _numerocalle) then
		let vmensaje = "El numero de la calle ya existe";
		let vcodigo = "000001";
	
	elif(vcodigo = "000000") then
	  insert into bdinteg:si_catcalles(numerocalle, nombrecalle, f_inserta, usr_modifica) 
         values (_numerocalle, UPPER(replace(_nombrecalle,'#','Ñ')), vfecha_hoy, _usuario);
		 --values (_numerocalle, UPPER(_nombrecalle), vfecha_hoy, _usuario);
  
  
    let vcodigo = "000000";
  	let vmensaje = "Registro exitoso";

	end if
	
    INSERT INTO bdicobranza:cb_bitacora_predictivo(transaccion, ip, fecha, hora, ejecutivo, apellido_pat, apellido_mat, pri_nombre, seg_nombre, codigo_retorno)
			VALUES('RPCALLE', NVL(TRIM(_Ip),''), TODAY, CURRENT HOUR TO SECOND, NVL(TRIM(_usuario),''),NVL(TRIM(_ApPat),''),
					    NVL(TRIM(_ApMat),''), NVL(TRIM(_Nom1),''), NVL(TRIM(_Nom2),''), vcodigo);
end if

  return vcodigo, vmensaje;
	
end;
end procedure;