create procedure "informix".sp_sw_ro_consmotivobloqcap(pIdUsuario char(8), pIdFuncion char(10))
	returning char(5) as codRet,
		char(2) as codigo_motivo,
		char(25) as descripcion
	
	define cCodRet char(5);
	define cCodMotivo char(2);
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodMotivo = '';
	let cDescripcion = '';
	let iSqlErr = 0;
	
	begin
		-- VALIDACIONES
		on exception set iSqlErr
			if iSqlErr <> 0 then
				let cCodRet = iSqlErr;
				return cCodRet, cCodMotivo, cDescripcion;
			end if;
		end exception;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--execute function bdinteg:sp_cnsif_confirmaejecutivo(pId_UsuarioC, pId_FuncionC) into cCodRet;
		--if cCodRet <> '00000'
		--	return cCodRet, cCodMotivo, cDescripcion;
		--end if;
		
		if pIdUsuario = '' or
			pIdFuncion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodMotivo, cDescripcion;
		end if;
		
		foreach select clave, descripcion
			into cCodMotivo, cDescripcion
			from bdicheq: sc_tipobloqueo order by 1
			
			return cCodRet, cCodMotivo, cDescripcion with resume;
			
		end foreach;
	end;
end procedure;