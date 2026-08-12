create procedure "informix".sp_sw_ro_conscausasbloqcred(pIdUsuario char(8), pIdFuncion char(10))
	returning char(5) as codRet,
		char(2) as causa_bloqueo,
		char(35) as descripcion
	
	define cCodRet char(5);
	define cCodBloq char(2);
	define cDescripcion char(35);
	define iSqlErr int;
	
	let cCodRet = '00000';
	let cCodBloq = '';
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
		execute function bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) into cCodRet;
		if cCodRet <> '00000' then
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		if pIdUsuario = '' or
			pIdFuncion = '' then
			
			let cCodRet = '00003';
			return cCodRet, cCodBloq, cDescripcion;
		end if;
		
		foreach select cod_causa, causa_bloq 
			into cCodBloq, cDescripcion
			from bdicred:sd_causa_bloqueo order by 1
			
			return cCodRet, cCodBloq, cDescripcion with resume;
			
		end foreach;
	end;
end procedure;