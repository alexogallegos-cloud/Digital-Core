create procedure "informix".sp_dep_edo_cta(vempresa char(3),vfecha date) 
returning varchar(6) as cod_ret; 

   --  variables de errores y datos de sp
   define  sql_err          integer;
   define  isam_err         integer;
   define  error_info       varchar(80);
   define  p_cod_ret        varchar(6);
   define  p_mensaje        varchar(30);
   
   -- variables definidas para la inserciÃ³n de datos
   define  vdfechafin       date; 
   define  vfechahoy        date;
   define  vfecharango      date;     
     
   --  variables para control de contadores
   define  vsflagentransaccion    char(1);
   define  vicontadorregistros    integer;
   define  vicontadorregistros2   integer;
   
   
   --  variables para datos de primary key         
   define  vfechafin   date;
   define  vcuenta     char(20);

   -- variables para la la nueva tabla sc_maehis_facelect_old
   define vempresaold      char(3);
   define vaniomesold      char(6);
   define vcuentaold       char(20);
   define vfechainiold     date;
   define vfechafinold     date;
   define vsdo_mes_antold  money;
   define vtotretirosold   money;
   define totdepositosold  money;
   define vsdo_actualold   money;

         
   --set debug file to "/informix/c90021641/aolg/error.out";
   --trace on;
   
   begin
   on exception set sql_err, isam_err, error_info
   let p_cod_ret  = sql_err;
   let p_mensaje  = error_info;
   
    return     p_cod_ret;
      
end exception;

--************************************************************
-- Creado por Ariel Omar Lara Gonzalez
-- fecha : Sep/2019
-- Funcion: Depurado de Tabla de Estados de Cuenta   
--************************************************************

-- Asignando valores a las variables para la TABLA sc_maehis_facelect
   let    vempresa    = vempresa;
   let    vcuenta     = '';
   let    vfechafin   = '';
   let	  vfechahoy   = '01011990';
   let    vfecharango = '01011990';

-- Asignando valores a las variables para la TABLA sc_maehis_facelect_old
   let    vempresaold      = '';
   let    vaniomesold      = '';
   let    vcuentaold       = '';
   let    vfechainiold     = '01011990';
   let    vfechafinold     = '01011990';
   let    vsdo_mes_antold  = 0.00;
   let    vtotretirosold   = 0.00;
   let    totdepositosold  = 0.00;
   let    vsdo_actualold   = 0.00;

   
-- Asignando valores a los CONTADORES  
   let    vsflagentransaccion  ='F';
   let    vicontadorregistros  = 0;
   let    vicontadorregistros2 = 0;

--Mensajes de Retorno
   let p_cod_ret = '00000';
	
	
   
   if( (vfecha is Null OR vfecha = '') OR (vempresa is Null OR vempresa = '')  ) then
   
      set isolation to dirty read;
      select fecha_hoy into vfechahoy from sc_fechas;  
	
      let vfecharango = DATE(vfechahoy - 18 UNITS MONTH); 
   else 
      let vfecharango  = vfecha;
   end if; 
	
	

      foreach cusor1 with hold
            for    
         select empresa, cuenta, fechafin 
               into vempresa, vcuenta, vfechafin 
            from bdicheq:"informix".sc_maehis_factelect
                where fechafin <= vfecharango 
			
         
         if(vsflagentransaccion = 'F') then
            begin work; -- INICIA EL CICLO
                let vsflagentransaccion = 'V';
            end if;
     
	set isolation to dirty read;
    set lock mode to wait 3;	 
        
    ---  Insertar registros into bdicheq:"informix".sc_maehis_factelect_old 
       select empresa, aniomes, cuenta, fechaini, fechafin, sdo_mes_ant, totretiros, totdepositos, sdo_actual 
               into vempresaold, vaniomesold, vcuentaold, vfechainiold, vfechafinold, vsdo_mes_antold, vtotretirosold, totdepositosold, vsdo_actualold
         from bdicheq:"informix".sc_maehis_factelect  
               where  empresa = vempresa     
                and   cuenta  = vcuenta 
                and   fechafin = vfechafin;
		
      insert into sc_maehis_factelect_old (empresa,aniomes,cuenta,fechaini,fechafin,sdo_mes_ant,totretiros,totdepositos,sdo_actual) 
            values (vempresaold,vaniomesold,vcuentaold,vfechainiold,vfechafinold,vsdo_mes_antold,vtotretirosold,totdepositosold,vsdo_actualold);
	
    --  Borra registro de la Tabla de Movimientos   
      delete from bdicheq:"informix".sc_maehis_factelect  
         where empresa = vempresa and
               cuenta  = vcuenta  and
               fechafin = vfechafin;
            
			   
	    let vicontadorregistros = vicontadorregistros + 1;
        let vicontadorregistros2 = vicontadorregistros2 + 1;

         if (vicontadorregistros2 = 100000) then 
            update statistics medium for table bdicheq:"informix".sc_maehis_factelect;       
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
            update statistics medium for table bdicheq:"informix".sc_maehis_factelect;   -- STATISTICS MEDIUM ?   
            let vsflagentransaccion = 'F';
      end if;
      
   --END IF;
   
   RETURN     p_cod_ret;

   --END IF;

END;

END PROCEDURE
;