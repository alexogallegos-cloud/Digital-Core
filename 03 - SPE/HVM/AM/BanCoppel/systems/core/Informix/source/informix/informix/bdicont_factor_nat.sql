create procedure "informix".factor_nat(v_naturaleza char(1))
returning smallint;

define v_factor smallint;

if v_naturaleza = "C" then
   let v_factor = -1;
else
   let v_factor = 1;
end if

return v_factor;

end procedure;