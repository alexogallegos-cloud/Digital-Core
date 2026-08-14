create procedure "informix".sp_sw_ro_constipobloqcred(pIdUsuario char(8), pIdFuncion char(10))
	returning char(5) as codRet,
		int as clave_bloqueo,
		char(25) as descripcion
	
	define cCodRet char(5);
	define cCodBloq char(2);
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodBloq = -1;
	let cDescripcion = '';
	let iSqlErr = 0;
	
	begin
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cCodBloq, cDescripcion;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--execute function bdinteg:sp_cnsif_confirmaejecutivo(pId_UsuarioC, pId_FuncionC) into cCodRet;
		--if cCodRet <> '00000'
		--	return cCodRet, cCodBloq, cDescripcion;
		--end if;
		
		if pIdUsuario = '' or
			pIdFuncion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		foreach select nvl(clave, 0), descripcion
			into cCodBloq, cDescripcion
			from bdicred:sd_bloqueoscuenta order by 1
			
			return cCodRet, cCodBloq, cDescripcion with resume;
			
		end foreach;
	end;
end procedure;