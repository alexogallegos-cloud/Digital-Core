create procedure "informix".num_valor( numero varchar(10))
returning int;


define longitud int;
define valor int;
define signo char(1);

let longitud = length(numero);

let signo = substr(numero,longitud,1);

if (signo = "+")
then 
  let valor = trim(substr(numero,1,longitud - 1));
elif  (signo = "-")
  then
     let valor = trim(substr(numero,1,longitud - 1));
     let valor = valor * -1;
else 
  let valor = trim(numero);
end if;

return valor;

end procedure;