create procedure "informix".genmovto1()
       returning char(3),char(20);

define vcodret char(3);
define vcuenta char(20);
define vtranret char(4);
define i integer;

foreach
   select cuenta into vcuenta
      from sc_maechq
   call abono('001','001','victorlp','0202','0202','victorlp10062609',
              vcuenta,0,10000,10000,0,0,0,'01')
        returning vcodret;
   if vcodret <> "000" then
      return vcodret,vcuenta;
   end if
end foreach
return vcodret,vcuenta;
end procedure;