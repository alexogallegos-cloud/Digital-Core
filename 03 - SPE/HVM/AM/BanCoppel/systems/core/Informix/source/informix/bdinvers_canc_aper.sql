create procedure "informix".canc_aper(pempresa char(3),
                                      pcuenta char(20)) 
returning char(5);


   -- **********************
   -- *  Define variables  *
   -- **********************
   define cod_ret char(5);
   define v_fecalta,v_fechoy date;
   define v_cal_int_inv char(1);
   define v_long_param,longitud smallint; 
   define v_numcte char(20);
   define v_contador, v_secuencia smallint;
   define sql_err integer;
   define vfolio_suc char(16);
   define vcta_cheques char(20);
   define vsucursal char(4);
   define vusuario char(8); 
   
   begin
   
   on exception set sql_err
      if sql_err > 0 then
         let cod_ret = sql_err;
      end if
   end exception

   -- **********************
   -- *  Asigna variables  *
   -- **********************
   let cod_ret = "000";

   select fecha_hoy 
     into v_fechoy 
     from sv_fechas 
    where empresa = pempresa;

   -- ***********************************************************
   -- * Verifica si existe la inversion y extrae su informacion *
   -- ***********************************************************
   select fecha_alta, num_cte, secuencia, cta_cheques, sucursal 
     into v_fecalta, v_numcte, v_secuencia, vcta_cheques, vsucursal 
     from sv_maeinv
    where empresa = pempresa
      and cuenta = pcuenta 
      and secuencia = 1;

   -- ******************
   -- *  Validaciones  *
   -- ******************
   -- // Verifica que la cuenta exista
   if v_fecalta is null then
      let cod_ret = "100";
      return cod_ret;
   end if

   -- // Verifica que la inversion fue aperturada el dia de hoy
   if v_fecalta <> v_fechoy then
      let cod_ret = "365";
      return cod_ret;
   end if

   -- // Cancela movimiento en cheques
   select folio_suc, usuario 
     into vfolio_suc, vusuario
     from sv_movdia
    where empresa = pempresa 
      and cuenta = pcuenta
      and transacc = "0500";

   call bdicheq:reversion(pempresa, vsucursal, vusuario, vfolio_suc,'A')
   returning cod_ret;

   -- // Cancela movs de inversiones
   update sv_movdia
      set cancelad = "S"
    where empresa = pempresa 
     and cuenta = pcuenta; 

   update sv_maeinv
     set  status_cta = '2', 
          fec_cancelac = v_fechoy
    where empresa = pempresa 
      and cuenta = pcuenta;

   delete from sv_maeinstrucc 
    where empresa = pempresa 
      and cuenta = pcuenta;

   delete from sv_benefic 
    where empresa = pempresa 
      and cuenta = pcuenta;

   delete from sv_cotitular 
    where cuenta = pcuenta 
      and empresa = pempresa;

   return cod_ret;

   end

end procedure;