CREATE PROCEDURE "informix".arr_clabe()


define vcta, vcta1 char(20);
define vctaclabe varchar(20);
define vplaza char(3);
define vcodret char(3);
define vdigverif char(1);

	FOREACH 
	 select trim(valor) || plazaclabe || trim(cuenta), cuenta_clabe,cuenta
	   INTO vcta, vctaclabe, vcta1
	   from sc_maechq a, bdinteg:si_param b, sc_plazaclabe c
	  where b.descripcion = "Banco"   
	    and c.sucursal = a.sucursal

	   call digverclabe(vcta)
           returning vcodret, vdigverif;

	   LET vcta = TRIM(vcta) || vdigverif;
	   IF vcta <> vctaclabe then
		update sc_maechq set cuenta_clabe = vcta
		 where cuenta = vcta1;
	
	   end if


	END FOREACH


END PROCEDURE
;