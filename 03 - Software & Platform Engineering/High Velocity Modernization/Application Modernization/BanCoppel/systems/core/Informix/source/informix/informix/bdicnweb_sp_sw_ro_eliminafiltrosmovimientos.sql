create procedure "informix".sp_sw_ro_eliminafiltrosmovimientos(pUsuario char(10), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int,
			pNumCliente char(20), pNumCuenta char(20), pSistemaCuenta char(2))

	returning char(5) as codret
	
	define iSqlErr int;
	define cCodRet char(5);
	
	let iSqlErr = 0;
	let cCodRet = '00000';
	
	begin
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		
		-- Validaciones de variables
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' then --or
			--pNumCliente = '' or pNumCuenta = '' or pSistemaCuenta = '' then
			
			let cCodRet = '00003';
			return cCodRet;
		end if;
		
		if pSistemaCuenta not in ('01', '03', '06') then
			let cCodRet = '00077';
			return cCodRet;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
		delete from sw_ro_filtros_movtos
		where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and id_oficio = pIdOficio;
			--and numcte = pNumCliente and cuenta = pNumCuenta and tipo_cuenta = pSistemaCuenta;
		
		return cCodRet;
		
	end;
	
end procedure;