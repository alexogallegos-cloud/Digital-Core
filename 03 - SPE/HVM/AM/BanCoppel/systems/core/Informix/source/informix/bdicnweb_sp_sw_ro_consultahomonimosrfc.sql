create procedure "informix".sp_sw_ro_consultahomonimosrfc(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pRegistros int, pRecuperacion int)
	returning char(5) as  codret,
		     char(13) as rfc 
			 
	define cCodRet char(5);
	define cRfc char(13);
	define iSqlErr int;
	define iIdBusqueda int;
	define iNoRegs int;
	
	let cCodRet = '00000';
	let cRfc = '';
	let iSqlErr = 0;
	let iIdBusqueda = 0;
	let iNoRegs = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cRfc;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pRegistros = '' or pRecuperacion = '' then
			let cCodRet = '00003';
			return cCodRet, cRfc;
		end if;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		IF cCodRet <> '00000' then
			return  cCodRet, cRfc;
		END IF;
		
		set isolation to dirty read;
		foreach 
			select skip pRegistros first pRecuperacion trim(b.rfc) as rfc
			into cRfc
			from sw_ro_resulper a, sw_ro_buscaper b
			where a.id_oficio = pIdOficio
				and b.id_tipobusqueda = 3
				and a.id_busqueda = b.id_busqueda
				and a.ind_omitir = 0 
				and a.status = 1
				and a.status_busqueda=2
			group by 1
			
			let iNoRegs = iNoRegs + 1;
		
			return cCodRet, cRfc with resume;
		end foreach;
		
		if iNoRegs = 0 then
			let cCodRet = '1001';
			return cCodRet, cRfc;
		end if;
	
	end;
end procedure;