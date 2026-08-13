create procedure "informix".cierrepdv(pempresa      char(3),
                           psucursal     char(3))
returning char(5);

   define cod_ret char(5);
   define v_existen,v_control smallint;
   define v_proceso char(4);
   define vw_proceso char(4);
   define sql_err integer;
   define vfecha_hoy date;




   
   
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret;
      end if;
   end exception;

-- *****************************************************************
-- Inicializa variables
-- *****************************************************************

   let cod_ret         = "000";
   let v_proceso       = "pase";
   let vw_proceso      = " ";

   select fechahoy into vfecha_hoy 
   from   so_fechas 
   where  empresaid = pempresa;
   -- Actualiza el control de procesos
   select proceso into vw_proceso from bdisuc:ss_contproc
   where  sucursal=psucursal and proceso = v_proceso;
   if vw_proceso is null then
      insert into bdisuc:ss_contproc
      values(psucursal,v_proceso,vfecha_hoy);
   else
      update bdisuc:ss_contproc
         set fecha = vfecha_hoy
       where sucursal=psucursal and proceso = v_proceso;
   end if
return cod_ret;
end procedure;