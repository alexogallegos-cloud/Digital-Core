create procedure "informix".sp_sw_ro_consareabloqcap(pIdUsuario char(8), pIdFuncion char(10))
	returning char(5) as codRet,
		char(2) as codigo_area,
		char(25) as descripcion
	
	define cCodRet char(5);
	define cCodArea char(2);
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodArea = '';
	let cDescripcion = '';
	let iSqlErr = 0;
	
	begin
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cCodArea, cDescripcion;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--execute function bdinteg:sp_cnsif_confirmaejecutivo(pId_UsuarioC, pId_FuncionC) into cCodRet;
		--if cCodRet <> '00000'
		--	return cCodRet, cCodArea, cDescripcion;
		--end if;
		
		if pIdUsuario = '' or
			pIdFuncion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodArea, cDescripcion;
		end if;
		
		foreach select clave, descripcion
			into cCodArea, cDescripcion
			from bdicheq:sc_areabloqueo order by 1
			
			return cCodRet, cCodArea, cDescripcion with resume;
			
		end foreach;
	end;
end procedure;