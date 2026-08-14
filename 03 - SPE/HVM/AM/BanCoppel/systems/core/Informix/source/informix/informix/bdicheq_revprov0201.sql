create procedure "informix".revprov0201()
returning char(5);


define vcodret char(5);
define vcuenta char(20);
define vfolio char(16);
define vsuc char(4);

--set debug file to "revprov.out";
--trace on;


--delete from analiza;

foreach select a.cuenta, a.folio_suc, a.sucursal
	  into vcuenta, vfolio, vsuc
	  from sc_movhis a, analiza b
	 where empresa = "001"
	   and transacc = "3276"
	   and fech_alt ="01/02/2008"
	   and cancelad <> "S"
	   and b.cuenta = a.cuenta
--	   and cuenta ="10000405570"


	call reverprov("001",vsuc, "informix", vfolio,"B", vcuenta)
	returning vcodret;
	if vcodret <> "000" then
		update analiza set actual = vcodret
	         where cuenta = vcuenta;
		--insert into analiza values (vcuenta, vcodret,0,0,0);
		let vcodret="000";
	end if
	


end foreach

return vcodret;

end procedure 
;