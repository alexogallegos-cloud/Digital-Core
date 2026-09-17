create procedure "informix".sp_sw_ro_guardanota(pUsuario char(8), pIdFuncion char(10), pIdOficio int, pIdBusqueda int, 
	pIdCliente int, pNota varchar(255), pIp char(15), pMacAddress char(12))
	returning
		char(5) as codret,
		int as secuencia
	
	define cCodRet char(5);
	define iSqlErr int;
	define iNumRegistro int;
	define iResulPer int;
	
	let cCodRet = '00000';
	let iSqlErr = 0;
	let iNumRegistro = 0;
	let iResulPer = 0;
	
	begin
	
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, iNumRegistro;
			end if;
		end exception;
		
		if pUsuario = '' or pIdFuncion = '' or pIdOficio = '' or pIdBusqueda = '' or pIdCliente = '' or
			pNota = '' or pIp = '' or pMacAddress = '' then
			
			let cCodRet = '00003';
			return cCodRet, iNumRegistro;
		end if;
		
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, iNumRegistro;
		end if;
		
		select id_resulper
		into iResulPer
		from sw_ro_resulper
		where id_busqueda = pIdBusqueda and id_oficio = pIdOficio;
		
		-- Se insertan los valores
		insert into sw_ro_notascte(id_resulcte, id_busqueda, id_oficio, id_resulper, nota, user_insert, ip_insert, mac_insert)
		values (pIdCliente, pIdBusqueda, pIdOficio, iResulPer, pNota, pUsuario, pIp, pMacAddress);
		
		let iNumRegistro = dbinfo('sqlca.sqlerrd1');
		return cCodRet, iNumRegistro;
		
	end;
end procedure;