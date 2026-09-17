create procedure "informix".busca_folio_comision(pempresa char(3),
                         pcuenta        char(20))
returning char(5), char(16);

   define vcodret 		char(5);
   define vsqlerr 		integer;
   define vempresa 		char(3);
   define vexiste 		integer;
   define vfolio_suc	char(16);

begin
   on exception set vsqlerr
      if vsqlerr <> 0 then
         let vcodret = vsqlerr;
         return vcodret, vfolio_suc;
      end if;
   end exception;

   let vcodret  = "000";
   let vexiste 	= 0;
   let vfolio_suc = "0000000000000000";

	if pempresa = "" or pcuenta = "" then

		let vcodret  = "001";
		return vcodret, vfolio_suc;

	end if;

	select count(*) 
	into vexiste
	from "informix".sc_movdia 
	where transacc = "3260" and cuenta = pcuenta;

	if vexiste <= 0 then

		let vcodret = "002";
		return vcodret, vfolio_suc;

	end if;
	
	select limit 1 folio_suc 
	into vfolio_suc
	from sc_movdia 
	where transacc = '3260' and cuenta = pcuenta  and cancelad <>'S';

	return vcodret, vfolio_suc;
	
end
end procedure;