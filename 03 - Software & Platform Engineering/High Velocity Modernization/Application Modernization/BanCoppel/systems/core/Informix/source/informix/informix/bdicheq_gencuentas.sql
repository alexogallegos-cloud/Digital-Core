create procedure "informix".gencuentas()
       returning char(3),char(20);

define vcodret char(3);
define vnumcte char(20);
define vcuenta char(20);
define i,vrowid integer;

foreach
   select rowid, numcte into vrowid,vnumcte
      from bdinteg:si_cliente
   call Cuenta1('001','victorlp','001','300',vnumcte,
                '01','1','1','001','victorlp','0','            ',
                0  ,'','','','','','',0,'N')
        returning vcodret,vcuenta;
   if vcodret <> "000" then
      return vcodret,vnumcte;
   end if
end foreach
return vcodret,vnumcte;
end procedure;