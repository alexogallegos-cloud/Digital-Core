create procedure "informix".acumdias(v_fecha date, v_fecval date)
returning smallint;

define v_dias smallint;

if year (v_fecha) = year(v_fecval) and
   month (v_fecha) = month(v_fecval) then
   let v_dias = day(v_fecha) - day(v_fecval) + 1;
else
   let v_dias = day(v_fecha);
end if

return v_dias;

end procedure;