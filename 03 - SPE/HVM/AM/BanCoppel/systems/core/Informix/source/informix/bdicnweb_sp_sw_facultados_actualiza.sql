create procedure "informix".sp_sw_facultados_actualiza(pId_UsuarioC char(8), pId_FuncionC char(10), pRolFuncion int, 
										pIdInstitucion1n int, pNombreFacultado char(80), pPuestoFacultado char(40),
										pStatus char(1),pTipoOperacion int, pId_Facultado int, pIp char(15), pMacAddress char(12))
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
		   (pRolFuncion is null or pRolFuncion = 0) or
		   pNombreFacultado= '' or
		   pPuestoFacultado='' or
		   pStatus= '' or
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
			insert into sw_ro_facultados(id_rolfuncion, id_institucion1n, nombre_facultado,puesto_facultado, status,user_insert, fecha_insert, ip_insert, mac_insert)
			values (pRolFuncion, pIdInstitucion1n, pNombreFacultado, pPuestoFacultado, pStatus, pId_UsuarioC, current, pIp, pMacAddress);
		elif pTipoOperacion = 2 then
			if pId_Facultado = 0 then
				let cCodRet = '00003';
			end if;	
			
			if pIdInstitucion1n = 0 then
				let pIdInstitucion1n = null;
			end if;
			
			update sw_ro_facultados set
				id_rolfuncion= pRolFuncion,
				id_institucion1n= pIdInstitucion1n,
				nombre_facultado = pNombreFacultado,
				puesto_facultado= pPuestoFacultado,
				status = pStatus,
				user_update = pId_UsuarioC,
				fecha_update = current,
				ip_update = pIp,
				mac_update = pMacAddress
			where id_facultado = pId_Facultado;
		end if;		
		return cCodRet;
	end;
		
end procedure;