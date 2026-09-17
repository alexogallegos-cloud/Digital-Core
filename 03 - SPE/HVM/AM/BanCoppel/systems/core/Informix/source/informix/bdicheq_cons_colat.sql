create procedure "informix".cons_colat(pempresa char(3),
                                       pcuenta char(20))
  returning char(5), char(20), char(20), char(20), char(20), char(20);

  define cod_ret char(5);
  define vcuenta,v_ctacol1,v_ctacol2,v_ctacol3,v_ctacol4,v_ctacol5 char(20);
  define longitud,v_long_cta smallint;

let cod_ret   = "000";
let v_ctacol1 = " ";
let v_ctacol2 = " ";
let v_ctacol3 = " ";
let v_ctacol4 = " ";
let v_ctacol5 = " ";


select cuenta into vcuenta
   from sc_maechq
   where empresa = pempresa and cuenta = pcuenta;
if vcuenta is null then
   let cod_ret = "100";
else
   select cta_col into v_ctacol1 from sc_colateral
      where empresa = pempresa and cuenta = pcuenta and secuencia = 1;
   select cta_col into v_ctacol2 from sc_colateral
      where empresa = pempresa and cuenta = pcuenta and secuencia = 2;
   select cta_col into v_ctacol3 from sc_colateral
      where empresa = pempresa and cuenta = pcuenta and secuencia = 3;
   select cta_col into v_ctacol4 from sc_colateral
      where empresa = pempresa and cuenta = pcuenta and secuencia = 4;
   select cta_col into v_ctacol5 from sc_colateral
      where empresa = pempresa and cuenta = pcuenta and secuencia = 5;
   if v_ctacol1 is null then
      let v_ctacol1 = " ";
   end if
   if v_ctacol2 is null then
      let v_ctacol2 = " ";
   end if
   if v_ctacol3 is null then
      let v_ctacol3 = " ";
   end if
   if v_ctacol4 is null then
      let v_ctacol4 = " ";
   end if
   if v_ctacol5 is null then
      let v_ctacol5 = " ";
   end if
end if;

  return cod_ret,v_ctacol1,v_ctacol2,v_ctacol3,v_ctacol4,v_ctacol5;

end procedure;