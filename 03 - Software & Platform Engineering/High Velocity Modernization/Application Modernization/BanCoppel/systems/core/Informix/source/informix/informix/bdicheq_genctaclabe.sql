create procedure "informix".genctaclabe()
       returning char(5);

define vcodret char(5);
define vcuenta char(20);
define vctaclabe char(18);


let vcodret = "000";

foreach
   select cuenta into vcuenta
      from sc_maechq
   call ctaclabe("001",vcuenta,"001")
        returning vcodret,vctaclabe;
   update sc_maechq
      set cuenta_clabe = vctaclabe
      where cuenta = vcuenta;
end foreach
return vcodret;
end procedure;