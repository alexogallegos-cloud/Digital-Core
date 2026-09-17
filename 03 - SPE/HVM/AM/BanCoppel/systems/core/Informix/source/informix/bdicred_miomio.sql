create procedure "informix".miomio()
returning  date, daTETIME YEAR TO MONTH;
define fecha daTETIME YEAR TO MONTH;
define fechahoy daTE;
select fecha_hoy into fechahoy
   from sd_fechas;
let fecha = fechahoy;
return
 fechahoy, fecha; 
end procedure;