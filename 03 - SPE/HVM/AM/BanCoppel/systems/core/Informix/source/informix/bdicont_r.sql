create procedure "informix".r(fecha date,  mes char(2))
   returning char(1);

    define retorno char(1);

   let retorno = " ";
   if (month(fecha) = mes) then
      let retorno = "V";
   else
      let retorno = "F";
   end if;
   return retorno;
end procedure;