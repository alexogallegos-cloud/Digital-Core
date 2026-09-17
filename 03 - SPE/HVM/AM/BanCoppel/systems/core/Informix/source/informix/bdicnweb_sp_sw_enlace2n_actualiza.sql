create procedure "informix".sp_sw_enlace2n_actualiza(pId_UsuarioC char(8), pId_FuncionC char(10), pDesc_i2n_NombreCorto char(50), 
										pDesc_i2n_NombreLargo char(100), pStatus_i2n char(1)
										,pTipoOperacion int, pId_Institucion2n int, pIp char(15), pMacAddress char(12))
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
		   pDesc_i2n_NombreCorto = '' or
		   pDesc_i2n_NombreLargo = '' or
		   pStatus_i2n   = '' or
		   pIp = '' or
		   pMacAddress = '' or 
		   (pTipoOperacion is null or pTipoOperacion = 0) then
		   
		   let cCodRet = '00003';
		   
		   return cCodRet;
		   
		end if;	
		
		if pTipoOperacion not in (1,2) then
			let cCodRet = '00087';
		   return cCodRet;
		end if;
		
	-- FIN DE VALIDACIONES
		if pTipoOperacion = 1 then  -- Alta de la Institución
			insert into sw_ro_inssolic2nivel(desc_i2n_nombrecorto, desc_i2n_nombrelargo, status, user_insert, fecha_insert, ip_insert, mac_insert)
			values (pDesc_i2n_NombreCorto, pDesc_i2n_NombreLargo, pStatus_i2n, pId_UsuarioC, current, pIp, pMacAddress);
		elif pTipoOperacion = 2 then
			if pId_Institucion2n = 0 then
				let cCodRet = '00003';
			end if;	
			update sw_ro_inssolic2nivel set
				desc_i2n_nombrecorto= pDesc_i2n_NombreCorto,
				desc_i2n_nombrelargo= pDesc_i2n_NombreLargo,
				status = pStatus_i2n,
				user_update = pId_UsuarioC,
				fecha_update = current,
				ip_update = pIp,
				mac_update = pMacAddress
			where id_institucion2n = pId_Institucion2n;
		end if;
		
		return cCodRet;
	end;
end procedure;