create procedure "informix".genmovtarj()
       returning char(3),char(4),date,money(14,2),money(14,2);

define vcodret char(3);
define vcuenta char(20);
define vnumtra char(4);
define vfechahoy date;
define vsaldo money(14,2);
define vmonto money(14,2);

foreach
   select numcuenta into vcuenta
      from tarjetacuenta
   call cargoref_td('203','20300000','1000','0001','20300000666666',
                    vcuenta,1,'01',' C075 1487920')
        returning vcodret,vnumtra,vfechahoy,vsaldo,vmonto;
end foreach
return vcodret,vnumtra,vfechahoy,vsaldo,vmonto;
end procedure;