create procedure "informix".diasmes(v_anio smallint, v_mes smallint)
returning smallint;

define v_dias smallint;

if v_mes = 1 or v_mes = 3 or v_mes = 5 or v_mes = 7 or
   v_mes = 8 or v_mes = 10 or v_mes = 12 then
   let v_dias = 31;
elif v_mes = 2 then
   if mod (v_anio, 4) = 0 then
      let v_dias = 29;
   else
      let v_dias = 28;
   end if
else
   let v_dias = 30;
end if

return v_dias;

end procedure;