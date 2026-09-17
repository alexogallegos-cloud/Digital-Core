create procedure "informix".cons_prom(pempresa char(3),
                                      pcuenta char(20))
  returning char(5),
            money(14,2), money(14,2), money(14,2), money(14,2),
            money(14,2), money(14,2);

  define cod_ret char(5);
  define tfecha,var_fec,tfechar datetime year to month;
  define v_cal_int_chq char(1);
  define vfecha_hoy date;
  define vcuenta, tcuenta, var_cta char(20);
  define vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4, vsdo_prom5,
         vsdo_prom6,tacum_pos money(14,2);
  define sql_err,i integer;
  define tdias_pos smallint;

-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************
  let cod_ret          = "000";
  let vsdo_prom1       = 0;
  let vsdo_prom2       = 0;
  let vsdo_prom3       = 0;
  let vsdo_prom4       = 0;
  let vsdo_prom5       = 0;
  let vsdo_prom6       = 0;


begin
   on exception set sql_err
      if sql_err <> 0 then
         let cod_ret = sql_err;
         return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
           vsdo_prom5, vsdo_prom6;
      end if;
   end exception;

-- ****************************************************************************
-- Valida exista la Cuenta de Cheques y extrae informacion necesaria
-- ****************************************************************************
select sc_maechq.cuenta
       into vcuenta
from sc_maechq
where empresa = pempresa and cuenta = pcuenta;

if vcuenta is null then
   let cod_ret = "100";
   return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
          vsdo_prom5, vsdo_prom6;
end if

 Select fecha_hoy into vfecha_hoy from sc_fechas
    where empresa = pempresa;

let tfecha = vfecha_hoy;
let i = 1;
while i < 7
    let tfecha = tfecha - 1 units month;
    begin
        let tfechar,tacum_pos, tdias_pos = (select fecha,acum_pos,dias_pos
            from sc_salpro
            where empresa = pempresa and cuenta = pcuenta and
                  fecha  = tfecha);
    end
    if tfechar is null then  
       let tacum_pos  = 0;
       let tdias_pos  = 0;
       let tfechar    = " ";
    end if
    if i = 1 then
       if tacum_pos > 0 then
         let vsdo_prom1 = tacum_pos/tdias_pos;
       else
         let vsdo_prom1 = 0;
       end if
    elif i = 2 then
       if tacum_pos > 0 then
         let vsdo_prom2 = tacum_pos/tdias_pos;
       else
         let vsdo_prom2 = 0;
       end if
    elif i = 3 then
       if tacum_pos > 0 then
         let vsdo_prom3 = tacum_pos/tdias_pos;
       else
         let vsdo_prom3 = 0;
       end if
    elif i = 4 then
       if tacum_pos > 0 then
         let vsdo_prom4 = tacum_pos/tdias_pos;
       else
         let vsdo_prom4 = 0;
       end if
    elif i = 5 then
       if tacum_pos > 0 then
         let vsdo_prom5 = tacum_pos/tdias_pos;
       else
         let vsdo_prom5 = 0;
       end if
    elif i = 6 then
       if tacum_pos > 0 then
         let vsdo_prom6 = tacum_pos/tdias_pos;
       else
         let vsdo_prom6 = 0;
       end if
    end if
    let i = i + 1;
    let var_cta = pcuenta;
    let var_fec = tfechar;
end while


-- ****************************************************************************
-- Verifica no enviar nulos como respuesta
-- ****************************************************************************
if vsdo_prom1 is null then
   let vsdo_prom1 = 0;
end if
if vsdo_prom2 is null then
   let vsdo_prom2 = 0;
end if
if vsdo_prom3 is null then
   let vsdo_prom3 = 0;
end if
if vsdo_prom4 is null then
   let vsdo_prom4 = 0;
end if
if vsdo_prom5 is null then
   let vsdo_prom5 = 0;
end if
if vsdo_prom6 is null then
   let vsdo_prom6 = 0;
end if
return cod_ret,vsdo_prom1, vsdo_prom2, vsdo_prom3, vsdo_prom4,
       vsdo_prom5, vsdo_prom6;

end
end procedure;