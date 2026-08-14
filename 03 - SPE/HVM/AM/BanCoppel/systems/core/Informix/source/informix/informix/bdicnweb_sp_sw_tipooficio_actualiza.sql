create procedure "informix".sp_sw_tipooficio_actualiza(pId_UsuarioC char(8), pId_FuncionC char(10), 
                                        pDescripcionOficio char(100), pStatus char(1), pTipoOperacion int,
                                        pIdOficio int, pIp char(15), pMacAddress char(12))
    returning char(5)

	define cCodRet char(5);
	define iSqlErr int;

	let cCodRet = '00000';
	let iSqlErr = 0;

	begin
		
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--execute function bdinteg:sp_cnsif_confirmaejecutivo(pId_UsuarioC, pId_FuncionC) into cCodRet;
		
		--if cCodRet <> '00000'
		--	return cCodRet;
		--end if;
		
		if pId_UsuarioC = '' or
		   pId_FuncionC = '' or
		   pDescripcionOficio = '' or
		   pStatus = '' or
		   pIp = '' or
		   pMacAddress = '' or 
		   pTipoOperacion = 0 then
		   
		   let cCodRet = '00003';
		   
		   return cCodRet;
		   
		end if;
		
		
		if pTipoOperacion not in (1,2) then
		   let cCodRet = '00087';
		   return cCodRet;
		end if;
		   
		-- FIN DE VALIDACIONES
		if pTipoOperacion = 1 then  -- Alta del Oficio
			insert into sw_ro_tipooficios(desc_tipooficio, status, user_insert, fecha_insert, ip_insert, mac_insert)
			values (pDescripcionOficio, pStatus, pId_UsuarioC, current, pIp, pMacAddress);
		elif pTipoOperacion = 2 then -- Actualizacion
			if pIdOficio = 0 then
				let cCodRet = '00003';
			end if;
			
			update sw_ro_tipooficios set
				desc_tipooficio = pDescripcionOficio,
				status = pStatus,
				user_update = pId_UsuarioC,
				fecha_update = current,
				ip_update = pIp,
				mac_update = pMacAddress
			where id_tipooficio = pIdOficio;
		end if;
		
		return cCodRet;
	end;
end procedure;