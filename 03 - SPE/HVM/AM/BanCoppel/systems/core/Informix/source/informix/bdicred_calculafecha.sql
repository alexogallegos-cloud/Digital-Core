create function "informix".calculafecha(pfecha char (10))

returning char(10);

define fechamov date;
define mes char(10);
define dia char(2);
define ano char(4);
define mesant smallint;
define mesantant smallint;
define sql_err int;
define i int;
define total int;
define vcodret char(5);


on exception set sql_err
let vcodret =  sql_err;
return vcodret;
--return vcodret,total,mes;
end exception;

--set debug file to "calfecha.out";
--trace on; 

let mes = "";
let dia = "";
let ano = "";
let i = 0;
let total = 0;
let mesant = 0;
let mesantant = 0;
let mes = month(date(pfecha));
let ano = year (date(pfecha));
let dia = day  (date(pfecha));
let fechamov = " ";

let vcodret = "000";

if dia = 31 then 
   if mes = 1 then let mesant = 31;
      elif mes = 3 then let mesant = 31;
      elif mes = 5 then let mesant = 31;
      elif mes = 7 then let mesant = 31;
      elif mes = 8 then let mesant = 31;
      elif mes = 10 then let mesant = 31;
      elif mes = 12 or mes = 0 then let mesant = 31;
   end if
elif dia = 30 then 
     if mes = 1  then  let mesant = 31;
        elif mes = 3 then let mesant = 30;
        elif mes = 4 then let mesant = 30;
        elif mes = 5 then let mesant = 30;
        elif mes = 6 then let mesant = 31;
        elif mes = 7 then let mesant = 30;
        elif mes = 8 then let mesant = 30;
        elif mes = 9 then let mesant = 30;
        elif mes = 10 then let mesant = 30;
        elif mes = 11 then let mesant = 31;
        elif mes = 12 or mes = 0 then let mesant = 30;
     end if
else	
     let mes = mes - 1;
     if mes = 1  then  let mesant = 31;
        elif mes = 2 then
             if mod(ano,4) = 0  then
                let  mesant = 28;
                else
                let mesant = 28;
             end if
        elif mes = 3 then let mesant = 31; 
        elif mes = 4 then let mesant = 30;
        elif mes = 5 then let mesant = 31;
        elif mes = 6 then let mesant = 30;
        elif mes = 7 then let mesant = 31;
        elif mes = 8 then let mesant = 31;
        elif mes = 9 then let mesant = 30;
        elif mes = 10 then let mesant = 31;
        elif mes = 11 then let mesant = 30;
        elif mes = 12 or mes = 0 then let mesant = 31;
     end if
end if 
select date(pfecha) - mesant  into fechamov from dual; 

return fechamov;

end function;