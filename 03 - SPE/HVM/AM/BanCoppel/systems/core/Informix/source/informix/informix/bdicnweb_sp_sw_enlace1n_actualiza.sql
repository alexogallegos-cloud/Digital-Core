create procedure "informix".sp_sw_enlace1n_actualiza(pId_UsuarioC char(8), pId_FuncionC char(10), pDesc_i1n_NombreCorto char(50), 
										pDesc_i1n_NombreLargo char(100), pDireccion_Oficio char(255) , pStatus_i1n char(1)
										,pTipoOperacion int, pId_Institucion1n int, pIp char(15), pMacAddress char(12))
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
		   pDesc_i1n_NombreCorto = '' or
		   pDesc_i1n_NombreLargo = '' or
		   pDireccion_Oficio   = '' or
		   pStatus_i1n   = '' or
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
			insert into sw_ro_insenlace1nivel(desc_i1n_nombrecorto, desc_i1n_nombrelargo, direccion_oficio, status, user_insert, fecha_insert, ip_insert, mac_insert)
			values (pDesc_i1n_NombreCorto, pDesc_i1n_NombreLargo, pDireccion_Oficio, pStatus_i1n, pId_UsuarioC, current, pIp, pMacAddress);
		elif pTipoOperacion = 2 then
			if pId_Institucion1n = 0 then
				let cCodRet = '00003';
			end if;	
			update sw_ro_insenlace1nivel set
				desc_i1n_nombrecorto= pDesc_i1n_NombreCorto,
				desc_i1n_nombrelargo= pDesc_i1n_NombreLargo,
				direccion_oficio= pDireccion_Oficio,
				status = pStatus_i1n,
				user_update = pId_UsuarioC,
				fecha_update = current,
				ip_update = pIp,
				mac_update = pMacAddress
			where id_institucion1n = pId_Institucion1n;
		end if;
		
		return cCodRet;
	end;
end procedure;