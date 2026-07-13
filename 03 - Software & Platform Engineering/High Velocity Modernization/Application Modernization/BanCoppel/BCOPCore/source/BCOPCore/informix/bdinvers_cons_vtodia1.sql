create procedure "informix".cons_vtodia1(pempresa char(3),
                                         psucursal char(4),
                                         pnummov   smallint)

returning char(5),char(20),money(14,2),money(14,2),money(14,2),date,
	  char(2),char(2),char(20);

-- ***************************************************************************
-- Define variables
-- ***************************************************************************
   define cod_ret char(5);
   define v_fechoy date;
   define v_cuenta char(20);
   define vstatus_cta,v_cal_int_inv char(1);
   define v_isr,v_intereses,v_capital,v_rend_neto money(14,2);
   define v_long_param,longitud smallint;
   define v_moneda     char(3);
   define v_ciclo      smallint;
   define v_instrucc1, v_instrucc2 char(2);
   define v_fechavenc  date;
   define v_num_cte    char(20);

   set isolation to dirty read;



-- ***************************************************************************
-- Asigna variables
-- ***************************************************************************
   let cod_ret     = "000";
   let v_capital   = 0;
   let v_rend_neto = 0;
   let v_cuenta    = " ";
   let v_ciclo     = 0;
   let v_num_cte   = "";

   select fecha_hoy into v_fechoy from sv_fechas where empresa = pempresa;

-- ***************************************************************************
-- Verifica si existe la inversion y extrae su informacion
-- ***************************************************************************
foreach
   select cuenta,status_cta,capital,intereses,isr, fecha_venc,
          sv_maeinv.num_cte
          into v_cuenta,vstatus_cta,v_capital,v_intereses,v_isr,
               v_fechavenc, v_num_cte
   from sv_maeinv
   where empresa = pempresa and sucursal = psucursal and
         fecha_venc = v_fechoy
   --    fecha_venc between v_fechoy and (v_fechoy + 9 units day)
   order by fecha_venc,cuenta

   let v_ciclo = v_ciclo + 1;
   if v_ciclo <= pnummov then
      continue foreach;
   end if

   --- Verifica el Total de Capital para reinversion
   select importe,inst_vento into v_capital, v_instrucc1 from sv_maeinstrucc
      where empresa = pempresa and cuenta = v_cuenta and cap_int = "C";
   if v_capital is null then
      let v_capital = 0;
   end if;

   --- Verifica el Total de Intereses para reinversion
   select (intereses - isr),
      inst_vento into v_rend_neto, v_instrucc2
     from sv_maeinv a,sv_maeinstrucc b
      where a.empresa = pempresa and a.cuenta = v_cuenta and
            a.empresa = b.empresa and a.cuenta = b.cuenta and
            cap_int = "I";
   if v_rend_neto is null then
      let v_rend_neto = 0;
   end if;

   return cod_ret,v_cuenta,v_capital,v_rend_neto,v_isr, v_fechavenc,
	  v_instrucc1, v_instrucc2, v_num_cte with resume;
end foreach
end procedure;