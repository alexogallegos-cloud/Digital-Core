create procedure "informix".sp_sw_ro_consnotas(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, pIdCliente int)
	returning
		char(5) as codret,
		int as secuencia,
		char(255) as nota
	
	define cCodRet char(5);
	define iSqlErr int;
	define iNoRegistros int;
	define iSecuenciaNota int;
	define cNota char(255);
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iSecuenciaNota = 0;
	let cNota = '';
	let iNoRegistros = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iSecuenciaNota, cNota;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' then
			let cCodRet = '00003';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iSecuenciaNota, cNota;
		end if;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		foreach
			select id_notascte, nota
			into iSecuenciaNota, cNota
			from sw_ro_notascte
			where id_resulcte = pIdCliente and id_busqueda = pIdBusqueda and id_oficio = pIdOficio
			order by id_notascte
			
			let iNoRegistros = iNoRegistros + 1;
		
			return cCodRet, iSecuenciaNota, cNota with resume;
			
		end foreach;
		
		if iNoRegistros = 0 then
			let cCodRet = '01001';
			return cCodRet, iSecuenciaNota, cNota;
		end if;
	end;
end procedure;