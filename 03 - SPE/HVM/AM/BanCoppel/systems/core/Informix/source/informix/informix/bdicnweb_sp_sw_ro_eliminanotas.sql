create procedure "informix".sp_sw_ro_eliminanotas(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCte int)
	returning
		char(5) as codret
	
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
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCte = '' then
			let cCodRet = '00003';
			return cCodRet;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet;
		end if;
		
		delete from sw_ro_notascte
		where id_resulcte = pIdCte and id_busqueda = pIdBusqueda and id_oficio = pIdOficio;

		return cCodRet;
		
	end;
end procedure;