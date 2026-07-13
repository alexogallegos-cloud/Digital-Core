create procedure "informix".genmovto()
       returning char(3),char(20);

define vcodret char(3);
define vcuenta char(20);
define vtranret char(4);
define i integer;

foreach
   select cuenta into vcuenta
      from sc_maechq
      where num_cte between '101018051' and '101068064'
   call abono('001','001','victorlp','0202','0202','victorlp18353904',
              vcuenta,0,100,100,0,0,0,'01')
        returning vcodret;
   if vcodret <> "000" then
      return vcodret,vcuenta;
   end if
   call cargo ('001','001','victorlp','0221','0202','victorlp18353904',
               vcuenta, 222, 100,'01')
        returning vcodret,vtranret;
   if vcodret <> "000" then
      return vcodret,vcuenta;
   end if
end foreach
return vcodret,vcuenta;
end procedure;