create procedure "informix".mismomes(v_fecha1 date, v_fecha2 date)
returning smallint;

define v_codigo smallint;

if month (v_fecha1) = month (v_fecha2) and
   year (v_fecha1) = year (v_fecha2) then
   let v_codigo = 1;
else
   let v_codigo = 0;
end if

return v_codigo;

end procedure;