CREATE PROCEDURE "informix".sp_second_multi_ocurrence()
       RETURNING char(6);

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(2);
DEFINE cCod_ret                     CHAR(6);
DEFINE vrowid                       INTEGER;
DEFINE vnumcuentaq                  CHAR(20);
define vcuenta 						integer;
define vfecha						char(6);

    --SET DEBUG FILE TO "/informix/Janeth_Peinado/Pruebas_shell/sp_depura_second.out";
    --TRACE ON; 

      LET cCod_ret      = '000000';
	  LET vnumcuentaq      = '';
	  LET sql_err       = 0;
	  LET isam_err      = 0;
	  LET error_info    = '';
	  LET cMensaje      = 'PROCESO EXITOSO';

	  BEGIN

ON EXCEPTION SET sql_err, isam_err, error_info
	LET cCod_ret = sql_err;
	LET cMensaje = error_info;
	RETURN cCod_ret;
END EXCEPTION;

   
SET ISOLATION TO dirty READ;
SET LOCK MODE TO wait 3;
            
FOREACH WITH HOLD
	select DISTINCT(numcuentaq) 
	into vnumcuentaq
	from sd_progesive_01
		
	let vcuenta = 1;	
	
	FOREACH WITH HOLD
	select fecha
	into vfecha
	from sd_progesive_01 
	where numcuentaq = vnumcuentaq
	order by fecha desc
		
		if vcuenta <= 9 then
			let cMensaje = "0" || vcuenta;
		else
			let cMensaje = vcuenta;
		end if
		
		update sd_progesive_01 set progresive_counter_quitar=cMensaje,progresive_counter=cMensaje
		where numcuentaq = vnumcuentaq and
		fecha = vfecha;
	   
	   let vcuenta = vcuenta + 1;
	   
	 END FOREACH; 
	 
END FOREACH; 

     RETURN cCod_ret;
	END;
	
END PROCEDURE;