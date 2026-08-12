create procedure "informix".sp_sw_ro_indinfocliente(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int,
							pIndRfc char(1), pIndEmpleo char(1), pIndDomicilio char(1))
	returning char(5) as codret
	
	define cCodRet char(5);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
			pIndRfc = '' or pIndEmpleo = '' or pIndDomicilio = '' then
			
			let cCodRet = '00003';
			return cCodRet;
		end if;
		
		if pIndRfc not in ('0', '1') or pIndEmpleo not in ('0', '1') or pIndDomicilio not in ('0', '1') then
			let cCodRet = '00087';
		end if;
		
		update sw_ro_resulcte
		set ind_rfc = pIndRfc,
			ind_empleo = pIndEmpleo,
			ind_domicilio = pIndDomicilio
		where id_busqueda = pIdBusqueda and id_oficio = pIdOficio and id_resulper = pIdCliente;
		
		return cCodRet;
	end;
	
end procedure;