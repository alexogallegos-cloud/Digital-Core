CREATE PROCEDURE "informix".altatardeb(pempresa char(3),
                        pcuenta         char(20),
                        pnumtarjeta     char(20),
                        pnumcte         char(20),
                        pexpiracion     date,
                        ptipo_tar       char(1),
                        pnombre         char(104),
                        pstatus         char(1),
                        plimite_aut     money (14, 2),
                        pproducto       char(4))

 Returning      char(5);

 
 define vcodret		char(5);
 define vsiguiente	integer;		
 define vexiste		integer;
 define vsqlerr		integer;
 define VexisTar	integer;
 define vlong		integer;
 
 
 let vcodret = "";
 let vsiguiente = 0;
 let vexiste= 0;
 let vsqlerr = 0;
 let VexisTar = 0;
 let vlong = 0;

 Begin

	On exception set vsqlerr		
		if vsqlerr<>0 then
			let vcodret = vsqlerr;
			return vcodret;
		end if;
	end exception;
  
 
 set isolation to dirty read;	
 SET LOCK MODE TO WAIT 2;
	
	let vcodret = "000";


	select max(secuencia) + 1 into vsiguiente
	from bdicheq:"informix".sc_tarjeta
	where empresa =pempresa and cuenta = pcuenta;       

	if vsiguiente is null then
		let vsiguiente = 1;
	end if;

	
	select 1 into vexiste from bdicheq:"informix".sc_tarjeta where empresa =pempresa and num_tarjeta=pnumtarjeta;
	if vexiste = 1 then
		let vcodret= "251";
	else	
		select valor into vlong from sc_param where empresa = '001' and codparam = 'longcta';
		if length(pcuenta) = vlong and length (pnumtarjeta) = 16 and bdinteg:"informix".val_num(pcuenta) and bdinteg:"informix".val_num(pnumtarjeta)  then -- se agraga validación para que la cuenta siempre sea de 11 digitos y tarjeta de 16
			insert into bdicheq:"informix".sc_tarjeta
			(empresa, cuenta, secuencia, num_tarjeta, numcte, expiracion, tipo_tarjeta, status_tar, limite_aut, prodtarjeta, nombre)
			 Values  (pempresa, pcuenta, vsiguiente, pnumtarjeta, pnumcte, pexpiracion, ptipo_tar, pstatus, plimite_aut, pproducto, pnombre);
		
		else
			let vcodret="131";
		end if;
	
	end if;
--	select 1 into vexiste 
--		from bdicheq:sc_tarjeta
--		where empresa=pempresa and cuenta=pcuenta and numcte=pnumcte and num_tarjeta=pnumtarjeta;
		
	
	return vcodret;
		
 end
 end procedure;